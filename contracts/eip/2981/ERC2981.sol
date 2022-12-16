/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   +@@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  -@@*     +@-  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    +@@-.#@#  =@%#.   :.     -@*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ +@#.-- .*%*. .#@@*@#  %@@%*#@@: .@@=-.         -%-   #%@:   +*-   =*@*   -@%=:
 * @@%   =##  +@@#-..%%:%.-@@=-@@+  ..   +@%  #@#*+@:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  +@*   #@#  +@@. -+@@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  =@=  :*@:=@@-:@+
 * -#%+@#-  :@#@@+%++@*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%+@#-   :*+**+=: %%++%*
 *
 * @title: ERC2981.sol
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Use case for EIP 2981
 * @custom:error-code EIP2981:E1 permille out of bounds
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

import "./IERC2981.sol";
import "../../errors/MaxErrors.sol";

abstract contract EIP2981 is MaxErrors
                           , IERC2981 {

  // Mapping Struct for Royalties
  struct mappedRoyalties {
    address receiver;
    uint16 permille;
  }

  // Mapping
  mapping(uint256 => mappedRoyalties) royalty;

  event royalatiesSet(uint token, address recipient, uint16 value);

  // the internals to do logic flows later

  // @dev to set roaylties on contract via EIP 2891
  // @param _receiver, address of recipient
  // @param _permille, permille xx.x -> xxx value
  function _setRoyalties(
    uint256 _tokenId
  , address _receiver
  , uint16 _permille
  ) internal {
  if (_permille >= 1000 || _permille == 0) {
    revert MaxSplaining({
      reason: "EIP2981:E1"
    });
  }

    royalty[_tokenId] = mappedRoyalties(_receiver, _permille);
    emit  royalatiesSet(_tokenId, _receiver, _permille);
  }

  // @dev to remove royalties from contract
  function _removeRoyalties(
    uint256 _tokenId
  ) internal {
    delete royalty[_tokenId];
    emit royalatiesSet(_tokenId, royalty[_tokenId].receiver, royalty[_tokenId].permille);
  }

  // Logic for this contract (abstract)

  // Left blank

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
    receiver = royalty[_tokenId].receiver;
    royaltyAmount = _salePrice * royalty[_tokenId].permille / 1000;
  }
}
