/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   +@@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  -@@*     +@-  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    +@@-.#@#  =@%#.   :.     -@*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ +@#.-- .*%*. .#@@*@#  %@@%*#@@: .@@=-.         -%-   #%@:   +*-   =*@*   -@%=:
 * @@%   =##  +@@#-..%%:%.-@@=-@@+  ..   +@%  #@#*+@:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  +@*   #@#  +@@. -+@@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  =@=  :*@:=@@-:@+
 * -#%+@#-  :@#@@+%++@*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%+@#-   :*+**+=: %%++%*
 *
 * @title: PaymentSplitterV2.sol
 * @author: rewritten by Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: was once an OZ payment splitter now, a maxflow payment splitter
 * @custom:OG-Source github.com/OpenZeppelin/openzeppelin-contracts/blob/0a87a4e75b02b95ca019d4894dc6e02e69e586f1/contracts/finance/PaymentSplitter.sol
 * @custom:error-code PSV2:E1 No Shares for address
 * @custom:error-code PSV2:E2 No payment due for address
 * @custom:error-code PSV2:E3 Can not use address(0)
 * @custom:error-code PSV2:E4 Shares can not be 0
 * @custom:error-code PSV2:E5 User has shares already
 * @custom:change-log added claim (msg.sender) for payment
 * @custom:change-log removed constructor, release, and ERC20 support
 * @custom:change-log added addPayee(address, uint)
 * @custom:change-log added removePayee(address, uint)
 * @custom:change-log added ERC165 with Interfaces IPaymentSplitter & IPaymentSplitterV2
 * @custom:change-log added custom error-codes above
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "./IPaymentSplitterV2.sol";
import "../../access/MaxAccess.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @dev This contract allows to split Ether payments among a group of accounts. The sender does not need to be aware
 * that the Ether will be split in this way, since it is handled transparently by the contract.
 *
 * The split can be in equal parts or in any other arbitrary proportion. The way this is specified is by assigning each
 * account to a number of shares. Of all the Ether that this contract receives, each account will then be able to claim
 * an amount proportional to the percentage of total shares they were assigned. The distribution of shares is set at the
 * time of contract deployment and can't be updated thereafter.
 *
 * `PaymentSplitter` follows a _pull payment_ model. This means that payments are not automatically forwarded to the
 * accounts but kept in this contract, and the actual transfer is triggered as a separate step by calling the {release}
 * function.
 */

abstract contract PaymentSplitterV2 is MaxAccess
                                     , IPaymentSplitterV2 {
  uint256 private _totalShares;
  uint256 private _totalReleased;
  mapping(address => uint256) private _shares;
  mapping(address => uint256) private _released;
  address[] private _payees;

  event PayeeAdded(address account, uint256 shares);
  event PayeeRemoved(address account, uint256 shares);
  event PayeesReset();
  event PaymentReleased(address to, uint256 amount);
  event PaymentReceived(address from, uint256 amount);

  /**
   * @dev The Ether received will be logged with {PaymentReceived} events. Note that these events are not fully
   * reliable: it's possible for a contract to receive Ether without triggering this function. This only affects the
   * reliability of the events, and not the actual splitting of Ether.
   *
   * To learn more about this see the Solidity documentation for
   * https://solidity.readthedocs.io/en/latest/contracts.html#fallback-function[fallback
   * functions].
   *
   *  receive() external payable virtual {
   *    emit PaymentReceived(msg.sender, msg.value);
   *  }
   *
   *  // Fallback function is called when msg.data is not empty
   *  // Added to PaymentSplitter.sol
   *  fallback() external payable {
   *    emit PaymentReceived(msg.sender, msg.value);
   *  }
   *
   * receive() and fallback() to be handled at final contract
   */

  // Internals of this contract

  // @dev: returns uint of payment for account in wei
  // @param account: account to lookup
  // @return: eth in wei
  function _pendingPayment(
    address account
  ) internal
    view
    returns (uint256) {
    uint totalReceived = address(this).balance + _totalReleased;
    return (totalReceived * _shares[account]) / _totalShares - _released[account];
  }

  // @dev: claims "eth" for user
  // @param user: address of user
  function _claimETH(
    address user
  ) internal {
    if (_shares[user] == 0) {
      revert MaxSplaining({
        reason: "PSV2:E1"
      });
    }

    uint256 payment = _pendingPayment(user);

    if (payment == 0) {
      revert MaxSplaining({
        reason: "PSV2:E2"
      });
    }

    // _totalReleased is the sum of all values in _released.
    // If "_totalReleased += payment" does not overflow,
    // then "_released[account] += payment" cannot overflow.
    _totalReleased += payment;
    unchecked {
      _released[user] += payment;
    }
    Address.sendValue(payable(user), payment);
    emit PaymentReleased(user, payment);
  }


  // @dev: this claims "eth" and ERC20 for all _payees[]
  function _payAll()
    internal {
    uint len = _payees.length;
    for (uint x = 0; x < len;) {
      _claimETH(_payees[x]);
      unchecked {
        ++x;
      }
    }
  }

  // @dev: this will add a payee to PaymentSplitterV3
  // @param account: address of account to add
  // @param shares: uint256 of shares to add to account
  function _addPayee(
    address account
  , uint256 addShares
  ) internal {
    if (account == address(0)) {
      revert MaxSplaining({
        reason: "PSV2:E3"
      });
    } else if (addShares == 0) {
      revert MaxSplaining({
        reason: "PSV2:E4"
      });
    } else if (_shares[account] > 0) {
      revert MaxSplaining({
        reason: "PSV2:E5"
      });
    }

    _payees.push(account);
    _shares[account] = addShares;
    _totalShares = _totalShares + addShares;

    emit PayeeAdded(account, addShares);
  }

  // @dev: finds index of an account in _payees
  // @param account: address of account to find
  // @return index: position of account in address[] _payees
  function _findIndex(
    address account
  ) internal
    view
    returns (uint index) {
    uint len = _payees.length;
    for (uint x = 0; x < len;) {
      if (_payees[x] == account) {
        index = x;
      }
      unchecked {
        ++x;
      }
    }
  }

  // @dev: removes an account in _payees
  // @param account: address of account to remove
  // @notice: will keep payment data in there
  function _removePayee(
    address account
  ) internal {
    if (account == address(0)) {
      revert MaxSplaining({
        reason: "PSV2:E3"
      });
    }

    // This finds the payee in the array _payees and removes it
    uint remove = _findIndex(account);
    address last = _payees[_payees.length - 1];
    _payees[remove] = last;
    _payees.pop();

    uint removeTwo = _shares[account];
    _shares[account] = 0;
    _totalShares = _totalShares - removeTwo;

    emit PayeeRemoved(account, removeTwo);
  }

  // @dev: this clears all shares/users from PaymentSplitterV3
  //       this WILL leave the payments already claimed on contract
  function _clearPayees()
    internal {
    uint len = _payees.length;
    for (uint x = 0; x < len;) {
      address account = _payees[x];
      _shares[account] = 0;
      unchecked {
         ++x;
      }
    }
    delete _totalShares;
    delete _payees;
    emit PayeesReset();
  }

  // Now the externals, listed by use

  // @dev: this claims all "eth" on contract for msg.sender
  function claim()
    external
    virtual
    override {
    _claimETH(msg.sender);
  }

  // @dev: This adds a payment split to PaymentSplitterV3.sol
  // @param newSplit: Address of payee
  // @param newShares: Shares to send user
  function addSplit (
    address newSplit
  , uint256 newShares
  ) external
    virtual
    override
    onlyDev() {
    _addPayee(newSplit, newShares);
  }

  // @dev: This pays all payment splits on PaymentSplitterV3.sol
  function paySplits()
    external
    virtual
    override
    onlyDev() {
    _payAll();
  }

  // @dev: This removes a payment split on PaymentSplitterV3.sol
  // @param remove: Address of payee to remove
  // @notice: use paySplits() prior to use if anything is on the contract
  function removeSplit (
    address remove
  ) external
    virtual
    override
    onlyDev() {
    _removePayee(remove);
  }

  // @dev: This removes all payment splits on PaymentSplitterV3.sol
  // @notice: use paySplits() prior to use if anything is on the contract
  function clearSplits()
    external
    virtual
    override
    onlyDev() {
    _clearPayees();
  }

  // @dev: returns total shares
  // @return: uint256 of all shares on contract
  function totalShares()
    external
    view
    virtual
    override
    returns (uint256) {
    return _totalShares;
  }

  // @dev: returns total releases in "eth"
  // @return: uint256 of all "eth" released in wei
  function totalReleased()
    external
    view
    virtual
    override
    returns (uint256) {
    return _totalReleased;
  }

  // @dev: returns shares of an address
  // @param account: address of account to return
  // @return: mapping(address => uint) of _shares
  function shares(
    address account
  ) external
    view
    virtual
    override
    returns (uint256) {
    return _shares[account];
  }

  // @dev: returns released "eth" of an account
  // @param account: address of account to look up
  // @return: mapping(address => uint) of _released
  function released(
    address account
  ) external
    view
    virtual
    override
    returns (uint256) {
    return _released[account];
  }

  // @dev: returns index number of payee
  // @param index: number of index
  // @return: address at _payees[index]
  function payee(
    uint256 index
  ) external
    view
    virtual
    override
    returns (address) {
    return _payees[index];
  }

  // @dev: returns amount of "eth" that can be released to account
  // @param account: address of account to look up
  // @return: uint in wei of "eth" to release
  function releasable(
    address account
  ) external
    view
    virtual
    override
    returns (uint256) {
    return _pendingPayment(account);
  }
}
