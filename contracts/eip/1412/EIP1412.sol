/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   +@@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  -@@*     +@-  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    +@@-.#@#  =@%#.   :.     -@*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ +@#.-- .*%*. .#@@*@#  %@@%*#@@: .@@=-.         -%-   #%@:   +*-   =*@*   -@%=:
 * @@%   =##  +@@#-..%%:%.-@@=-@@+  ..   +@%  #@#*+@:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  +@*   #@#  +@@. -+@@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  =@=  :*@:=@@-:@+
 * -#%+@#-  :@#@@+%++@*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%+@#-   :*+**+=: %%++%*
 *
 * @title: Batch Transfers For Non-Fungible Tokens
 * @author: Nick Mudge nick@mokens.io
 * @notice: Adds batch transfer functions for ERC721 non-fungible tokens.
 * @custom: Change log added ERC165 into this, added event TransferBatch and changed to Apache2.0
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

///  Note: the ERC-165 identifier for this interface is 0x2b89bcaa

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface EIP1412 is IERC165 {

  // @notice this is the event emitted for batch transfer
  // @param operator - msg.sender
  // @param from - address from
  // @param to - addres sent to
  // @param ids - list/array of token id's that transferred
  event TransferBatch(
    address indexed operator,
    address indexed from,
    address indexed to,
    uint256[] ids
  );

  // @notice Transfers the ownership of multiple NFTs from one address to another address
  // @param _from The current owner of the NFT
  // @param _to The new owner
  // @param _tokenIds The NFTs to transfer
  // @param _data Additional data with no specified format, sent in call to `_to`  
  function safeBatchTransferFrom(
    address _from
  , address _to
  , uint256[] memory _tokenIds
  , bytes memory _data
  ) external;
  
  // @notice Transfers the ownership of multiple NFTs from one address to another address
  // @param _from The current owner of the NFT
  // @param _to The new owner
  // @param _tokenIds The NFTs to transfer  
  function safeBatchTransferFrom(
    address _from
  , address _to
  , uint256[] memory _tokenIds
  ) external;

}
