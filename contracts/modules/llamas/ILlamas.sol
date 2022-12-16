/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   +@@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  -@@*     +@-  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    +@@-.#@#  =@%#.   :.     -@*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ +@#.-- .*%*. .#@@*@#  %@@%*#@@: .@@=-.         -%-   #%@:   +*-   =*@*   -@%=:
 * @@%   =##  +@@#-..%%:%.-@@=-@@+  ..   +@%  #@#*+@:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  +@*   #@#  +@@. -+@@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  =@=  :*@:=@@-:@+
 * -#%+@#-  :@#@@+%++@*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%+@#-   :*+**+=: %%++%*
 *
 * @title: ILlamas.sol
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Interface for Llama/BAYC Mint engine, does Provenance for Metadata/Images
 * Source: https://etherscan.io/address/0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d#code
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

import "./IMAX721.sol";

interface ILlamas is IMAX721{

  // @dev: will return Provenance hash of images
  // @return: string memory of the Images Hash (sha256)
  function RevealProvenanceImages()
    external
    view
    returns (string memory);

  // @dev: will return Provenance hash of metadata
  // @return: string memory of the Metadata Hash (sha256)
  function RevealProvenanceJSON()
    external
    view
    returns (string memory);

  // @dev: will return starting number for mint
  // @return: uint of the start number
  function RevealStartID()
    external
    view
    returns (uint256);

  // @dev this will set the boolean for minter status
  // @param toggle: bool for enabled or not
  function setStatus(
    bool toggle
  ) external;

  // @dev this will set the minter fees
  // @param number: uint for fees in wei.
  function setMintFees(
    uint number
  ) external;

  // @dev this will set the Provenance Hashes
  // @param string memory img - Provenance Hash of images in sequence
  // @param string memory json - Provenance Hash of metadata in sequence
  // @notice: This will set the start number as well, make sure to set MaxCap
  //  also can be a hyperlink... sha3... ipfs.. whatever.
  function setProvenance(
    string memory img
  , string memory json
  ) external;

  // @dev this will set the mint engine
  // @param mintingCap: uint for publicMint() capacity of this chain
  // @param teamMints: uint for maximum teamMints() capacity on this chain
  function setLlamasEngine(
    uint mintingCap
  , uint teamMints
  ) external;
}

