/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   +@@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  -@@*     +@-  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    +@@-.#@#  =@%#.   :.     -@*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ +@#.-- .*%*. .#@@*@#  %@@%*#@@: .@@=-.         -%-   #%@:   +*-   =*@*   -@%=:
 * @@%   =##  +@@#-..%%:%.-@@=-@@+  ..   +@%  #@#*+@:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  +@*   #@#  +@@. -+@@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  =@=  :*@:=@@-:@+
 * -#%+@#-  :@#@@+%++@*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%+@#-   :*+**+=: %%++%*
 *
 * @title: ERC2981Collection.sol
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Use case for EIP 2981, steered more towards NFT Collections as a whole
 * @custom:error-code ERC2981:E1 permille out of bounds
 * @custom:change-log added custom error code
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

import "./IMAX2981.sol";
import "../../access/MaxAccess.sol";

abstract contract ERC2981 is MaxAccess
                           , IMAX2981 {

  address internal royaltyAddress;
  uint16 internal royaltyPermille;

  event royalatiesSet(
          uint16 value
        , address recipient
        );

  // the internals to do logic flows later

  // @dev to set roaylties on contract via EIP 2981
  // @param _receiver, address of recipient
  // @param _permille, permille xx.x -> xxx value
  function _setRoyalties(
    address _receiver
  , uint16 _permille
  ) internal {
  if (_permille >= 1000 || _permille == 0) {
    revert MaxSplaining({
      reason: "ERC2981:E1"
    });
  }
    royaltyAddress = _receiver;
    royaltyPermille = _permille;
    emit royalatiesSet(royaltyPermille, royaltyAddress);
  }

  // @dev to remove royalties from contract
  function _removeRoyalties()
    internal {
    delete royaltyAddress;
    delete royaltyPermille;
    emit royalatiesSet(royaltyPermille, royaltyAddress);
  }

  // Logic for this contract (abstract)

  // @notice: This sets the contract as royalty reciever (useful with abstract PaymentSplitter)
  // @param permille: Percentage you want so 3.5% -> 35
  function setRoyaltiesThis(
    uint16 permille
  ) external
    virtual
    override
    onlyOwner() {
    _setRoyalties(address(this), permille);
  }

  // @notice: This sets royalties per EIP-2981
  // @param newAddress: Sets the address for royalties
  // @param permille: Percentage you want so 3.5% -> 35
  function setRoyalties(
    address newAddress
  , uint16 permille
  ) external
    virtual
    override
    onlyOwner() {
    _setRoyalties(newAddress, permille);
  }

  // @notice: Clears EIP2981 royalties
  function clearRoyalties()
    external
    virtual
    override
    onlyOwner() {
    _removeRoyalties();
  }

  // @dev Override for royaltyInfo(uint256, uint256)
  // @param _tokenId, uint of token ID to be checked
  // @param _salePrice, uint of amount of sale
  // @return receiver, address of recipient
  // @return royaltyAmount, amount royalties recieved
  function royaltyInfo(
    uint256 _tokenId
  , uint256 _salePrice
  ) external
    view
    virtual
    override
    returns (
    address receiver
  , uint256 royaltyAmount
  ) {
    receiver = royaltyAddress;
    royaltyAmount = _salePrice * royaltyPermille / 1000;
  }
}
