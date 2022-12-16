/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   +@@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  -@@*     +@-  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    +@@-.#@#  =@%#.   :.     -@*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ +@#.-- .*%*. .#@@*@#  %@@%*#@@: .@@=-.         -%-   #%@:   +*-   =*@*   -@%=:
 * @@%   =##  +@@#-..%%:%.-@@=-@@+  ..   +@%  #@#*+@:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  +@*   #@#  +@@. -+@@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  =@=  :*@:=@@-:@+
 * -#%+@#-  :@#@@+%++@*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%+@#-   :*+**+=: %%++%*
 *
 * @title: Llamas.sol
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Solidity from the BAYC Mint engine, does Provenance for Images
 * @custom:OG-Source: https://etherscan.io/address/0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d#code
 * @custom:error-code Llamas:E1 msg.value is under quant * fees
 * @custom:error-code Llamas:E2 minter is paused
 * @custom:error-code Llamas:E3 states not loaded
 * @custom:error-code Llamas:E4 provenance is locked
 * @custom:error-code Llamas:E5 can not change provenance while minting
 * @custom:change-log added provenance to metadata
 * @custom:change-log used the modulo division to wrap from start -> last ID -> first ID -> start
 * @custom:change-log bug found, line 61 corrected >= to <
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

import "./ILlamas.sol";
import "../../lib/PsuedoRand.sol";
import "../../lib/CountersV2.sol";
import "../../access/MaxAccess.sol";

abstract contract Llamas is MaxAccess
                          , ILlamas {

  using PsuedoRand for PsuedoRand.Engine;
  using CountersV2 for CountersV2.Counter;

  PsuedoRand.Engine private llamas;
  CountersV2.Counter private tokensBurned;

  event SetStartNumbers(uint numberToMint, uint teamMints);

  modifier paidMint(uint quant) {
    if (msg.value < quant * llamas.mintFee) {
      revert MaxSplaining({
        reason: "Llamas:E1"
      });
    }
    _;
  }

  modifier notPaused() {
    if (!llamas.status) {
      revert MaxSplaining({
        reason: "Llamas:E2"
      });
    }
    _;
  }

  modifier numbersSet() {
    if (llamas.maxCapacity == 0) {
      revert MaxSplaining({
        reason: "Llamas:E3"
      });
    }
    _;
  }

  modifier provenanceLocked() {
    if (llamas.provSet) {
      revert MaxSplaining({
        reason: "Llamas:E4:"
      });
    }
    if (llamas.showMinted() > 0) {
      revert MaxSplaining({
        reason: "Llamas:E5"
      });
    }
    _;
  }

  // @dev this is to substract one to on chain minted
  function _subOne()
    internal {
    tokensBurned.increment();
  }

  // @dev this is for any team mint that happens, must be included in mint...
  function _oneTeamMint()
    internal {
    llamas.battersUp();
    llamas.battersUpTeam();
  }

  // @dev this is for any mint outside of a team mint, must be included in mint...
  function _oneRegularMint()
    internal {
    llamas.battersUp();
  }

  // @dev this will set the boolean for minter status
  // @param toggle: bool for enabled or not
  function _setStatus(
    bool toggle
  ) internal {
    llamas.setStatus(toggle);
  }

  // @dev this will set the minter fees
  // @param number: uint for fees in wei.
  function _setMintFees(
    uint number
  ) internal {
    llamas.setFees(number);
  }

  // @dev this will set the mint engine
  // @param _mintingCap: uint for publicMint() capacity of this chain
  // @param _teamMints: uint for maximum teamMints() capacity on this chain
  function _setLlamasEngine(
    uint _mintingCap
  , uint _teamMints
  ) internal {
    llamas.setMaxCap(_mintingCap);
    llamas.setMaxTeam(_teamMints);

    emit SetStartNumbers(
      _mintingCap
    , _teamMints
    );
  }

  // @dev this will set the Provenance Hashes
  // @param string memory img - Provenance Hash of images in sequence
  // @param string memory json - Provenance Hash of metadata in sequence
  // @notice: This will set the start number as well, make sure to set MaxCap
  //  also can be a hyperlink... sha3... ipfs.. whatever.
  function _setProvenance(
    string memory img
  , string memory json
  ) internal {
    llamas.setProvJSON(json);
    llamas.setProvIMG(img);
    llamas.setStartNumber();
    llamas.provLock();
  }

  // @dev this will be valuable on the mint engine logic contract
  function _nextUp()
    internal
    view
    returns (uint) {
    return llamas.mintID();
  }

  // @dev this will set the boolean for minter status
  // @param toggle: bool for enabled or not
  function setStatus(
    bool toggle
  ) external
    virtual
    override
    onlyDev() {
    _setStatus(toggle);
  }

  // @dev this will set the minter fees
  // @param number: uint for fees in wei.
  function setMintFees(
    uint number
  ) external
    virtual
    override
    onlyDev() {
    _setMintFees(number);
  }

  // @dev this will set the mint engine
  // @param mintingCap: uint for publicMint() capacity of this chain
  // @param teamMints: uint for maximum teamMints() capacity on this chain
  function setLlamasEngine(
    uint mintingCap
  , uint teamMints
  ) external
    virtual
    override
    onlyDev() {
    _setLlamasEngine(
      mintingCap
    , teamMints
    );
  }

  // @dev this will set the Provenance Hashes
  // @param string memory img - Provenance Hash of images in sequence
  // @param string memory json - Provenance Hash of metadata in sequence
  // @notice: This will set the start number as well, make sure to set MaxCap
  //  also can be a hyperlink... sha3... ipfs.. whatever.
  function setProvenance(
    string memory img
  , string memory json
  ) external
    virtual
    override
    numbersSet()
    provenanceLocked()
    onlyDev() {
    _setProvenance(
      img
    , json
    );
  }

  // @dev will return status of Minter
  // @return - bool of active or not
  function minterStatus()
    external
    view
    virtual
    override
    returns (bool) {
    return llamas.status;
  }

  // @dev will return minting fees
  // @return - uint of mint costs in wei
  function minterFees()
    external
    view
    virtual
    override
    returns (uint) {
    return llamas.mintFee;
  }

  // @dev will return maximum mint capacity
  // @return - uint of maximum mints allowed
  function minterCapacity()
    external
    view
    virtual
    override
    returns (uint) {
    return llamas.maxCapacity;
  }

  // @dev will return maximum mint capacity
  // @return - uint of maximum mints allowed
  function minterMinted()
    external
    view
    virtual
    override
    returns (uint) {
    return llamas.showMinted();
  }

  // @dev will return maximum "team minting" capacity
  // @return - uint of maximum airdrops or team mints allowed
  function minterTeamMintsCapacity()
    external
    view
    virtual
    override
    returns (uint) {
    return llamas.maxTeamMints;
  }

  // @dev will return "team mints" count
  // @return - uint of airdrops or team mints done
  function minterTeamMintsMinted()
    external
    view
    virtual
    override
    returns (uint) {
    return llamas.showTeam();
  }

  // @dev: will return total supply for mint
  // @return: uint for this mint
  function totalSupply()
    external
    view
    virtual
    override
    returns (uint256) {
    return llamas.showMinted() - tokensBurned.current();
  }

  // @dev: will return Provenance hash of images
  // @return: string memory of the Images Hash (sha256)
  function RevealProvenanceImages() 
    external 
    view 
    virtual
    override 
    returns (string memory) {
    return llamas.ProvenanceIMG;
  }

  // @dev: will return Provenance hash of metadata
  // @return: string memory of the Metadata Hash (sha256)
  function RevealProvenanceJSON()
    external
    view
    virtual
    override
    returns (string memory) {
    return llamas.ProvenanceJSON;
  }

  // @dev: will return starting number for mint
  // @return: uint of the start number
  function RevealStartID()
    external
    view
    virtual
    override
    returns (uint256) {
    return llamas.startNumber;
  }
}
