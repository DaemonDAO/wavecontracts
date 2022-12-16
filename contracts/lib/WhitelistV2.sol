/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   +@@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  -@@*     +@-  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    +@@-.#@#  =@%#.   :.     -@*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ +@#.-- .*%*. .#@@*@#  %@@%*#@@: .@@=-.         -%-   #%@:   +*-   =*@*   -@%=:
 * @@%   =##  +@@#-..%%:%.-@@=-@@+  ..   +@%  #@#*+@:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  +@*   #@#  +@@. -+@@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  =@=  :*@:=@@-:@+
 * -#%+@#-  :@#@@+%++@*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%+@#-   :*+**+=: %%++%*
 *
 * @title: Whitelist.sol
 * @author: @MaxFlowO2 on bird app/GitHub
 * @notice: Provides a whitelist capability that can be added to and removed easily.
 * @custom:error-code Lib-WL:E1 Whitelist already enabled
 * @custom:error-code Lib-WL:E2 Whitelist already disabled
 * @custom:error-code Lib-WL:E3 User already Whitelisted
 * @custom:error-code Lib-WL:E4 User not Whitelisted
 * @custom:change-log Custom errors added above
 *
 * Include with 'using WhitelistV2 for WhitelistV2.List;'
 *
 * This edition is address => uint so you can have a quant per wl address
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

import "./CountersV2.sol";

library WhitelistV2 {
  using CountersV2 for CountersV2.Counter;

  event WhiteListEndChanged(uint _old, uint _new);
  event WhiteListChanged(bool _current, uint _quant, address _address);
  event WhiteListStatus(bool _old, bool _new);

  // @dev: this is MaxSplaining(), giving you a reason, aka require(param, "reason")
  // @param reason: Use the "Contract name: error"
  // @notice: 0x0661b792 bytes4 of this
  error MaxSplaining(
    string reason
  );

  struct List {
    // These variables should never be directly accessed by users of the library: interactions must be restr>
    // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to>
    // this feature: see https://github.com/ethereum/solidity/issues/4637
    bool enabled; //default is false,
    mapping(address => uint) _quant; // all values default to zero
  }

  function wlMint(
    List storage list
  , address _address
  ) internal {
    // Using this a bit
    uint check = list._quant[_address];
    // If zero revert
    if (check == 0) {
      revert  MaxSplaining({
        reason : "Lib-WL:E4"
      });
    }
    // has to be positive, can unckeck the decrement
    unchecked { --check; }
    // now the new wl value
    list._quant[_address] = check;
    // emit event
    emit WhiteListChanged(true, list._quant[_address], _address);
  }

  function add(
    List storage list
  , address _address
  , uint _amount
  ) internal {
    if (list._quant[_address] > 0) {
      revert  MaxSplaining({
        reason : "Lib-WL:E3"
      });
    }
    // since now all previous values are false no need for another variable
    // and add them to the list!
    list._quant[_address] = _amount;
    // emit event
    emit WhiteListChanged(true, list._quant[_address], _address);
  }

  function remove(
    List storage list
  , address _address
  ) internal {
    if (list._quant[_address] == 0) {
      revert  MaxSplaining({
        reason : "Lib-WL:E4"
      });
    }
    // since now all previous values are true no need for another variable
    // and remove them from the list!
    list._quant[_address] = 0;
    // emit event
    emit WhiteListChanged(false, list._quant[_address], _address);
  }

  function enable(
    List storage list
  ) internal {
    if (list.enabled) {
      revert  MaxSplaining({
        reason : "Lib-WL:E1"
      });
    }
    list.enabled = true;
    emit WhiteListStatus(false, list.enabled);
  }

  function disable(
    List storage list
  ) internal {
    if (!list.enabled) {
      revert  MaxSplaining({
        reason : "Lib-WL:E2"
      });
    }
    list.enabled = false;
    emit WhiteListStatus(true, list.enabled);
  }

  function status(
    List storage list
  ) internal
    view
    returns (bool) {
    return list.enabled;
  }

  function onList(
    List storage list
  , address _address
  ) internal
    view
    returns (bool) {
    return list._quant[_address] > 0;
  }
}
