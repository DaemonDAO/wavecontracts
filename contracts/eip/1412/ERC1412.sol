/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   +@@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  -@@*     +@-  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    +@@-.#@#  =@%#.   :.     -@*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ +@#.-- .*%*. .#@@*@#  %@@%*#@@: .@@=-.         -%-   #%@:   +*-   =*@*   -@%=:
 * @@%   =##  +@@#-..%%:%.-@@=-@@+  ..   +@%  #@#*+@:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  +@*   #@#  +@@. -+@@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  =@=  :*@:=@@-:@+
 * -#%+@#-  :@#@@+%++@*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%+@#-   :*+**+=: %%++%*
 *
 * @title: ERC721BatchTransfer.sol
 * @author: @MaxFlowO2 on bird app/GitHub
 * @notice: Provides a batch transfer capability that can be added to ERC 721 via EIP 1412 (V2).
 * @custom:error-code ERC721BT:E1 to.length tokenId.length mismatch
 * @custom:change-log added custom errors above
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

import "./EIP1412.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

abstract contract ERC1412 is EIP1412
                           , ERC721
                           , ERC721Burnable {

  constructor(
    string memory _name
  , string memory _ticker
  ) ERC721(_name, _ticker) {}

  function safeBatchTransferFrom(
    address from,
    address to,
    uint256[] memory tokenIds
  ) public
    virtual
    override {
    safeBatchTransferFrom(from, to, tokenIds, "");
  }

  function safeBatchTransferFrom(
    address from,
    address to,
    uint256[] memory tokenIds,
    bytes memory _data
  ) public
    virtual
    override {
    uint len = tokenIds.length;
    for(uint x = 0; x < len;) {
      _safeTransfer(from, to, tokenIds[x], _data);
      unchecked { ++x; }
    }
    emit TransferBatch(msg.sender, from, to, tokenIds);
  }
}
