/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   +@@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  -@@*     +@-  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    +@@-.#@#  =@%#.   :.     -@*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ +@#.-- .*%*. .#@@*@#  %@@%*#@@: .@@=-.         -%-   #%@:   +*-   =*@*   -@%=:
 * @@%   =##  +@@#-..%%:%.-@@=-@@+  ..   +@%  #@#*+@:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  +@*   #@#  +@@. -+@@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  =@=  :*@:=@@-:@+
 * -#%+@#-  :@#@@+%++@*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%+@#-   :*+**+=: %%++%*
 *
 * @title: WaveDaemons NFT Minter
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: ERC-721/1412/2981 compliant contract set with burn()
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

import "./eip/1412/ERC1412.sol";
import "./eip/2981/ERC2981Collection.sol";
import "./modules/timecop/TimeCop.sol";
import "./modules/splitter/PaymentSplitterV2.sol";
import "./modules/llamas/Llamas.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract WaveDaemons is TimeCop
                      , ERC2981
                      , PaymentSplitterV2
                      , Llamas
                      , ERC1412
                      , ReentrancyGuard {

  using Strings for uint256;

  string base;
  address Tinys = address(0x8bb765AE3e2320fd9447889D10b9DC7CE4970DA5);

  event UpdatedBaseURI(string _old, string _new);
  event ThankYou(address user, uint amount);

  constructor() ERC1412("WaveDaemons", "WAVEDMN") {}

  function burnToMint(
    uint256[] ids
  ) external
    notPaused()
    onlySale()
    nonReentrant() {
    // now to get the five per
    uint256 quant = ids.length / 5;
    if (quant == 0) {
      revert MaxSplaining({
        reason: "Main:B1"
      });
    } else {
      for (uint x = 0; x < quant;) {
        _safeMint(msg.sender, _nextUp());
        _oneRegularMint();
        unchecked { ++x; }
      }
      // must call Approve for all first
      for (uint y = 0; y < quant * 5;) {
        ERC721Burnable(Tinys).burn(ids[y]);
      }
   }

  function publicMint(
    uint quant
  ) external
    payable
    notPaused()
    onlySale()
    paidMint(quant)
    nonReentrant() {
    if (this.minterMinted() + quant > this.minterCapacity()) {
      revert MaxSplaining ({
        reason: "Main:S1"
      });
    }
    for (uint x = 0; x < quant;) {
      _safeMint(msg.sender, _nextUp());
      _oneRegularMint();
      unchecked { ++x; }
    }
  }


  function teamMint(
    uint256 quant
  ) external
    onlyOwner() {
    if (this.minterMinted() + quant > this.minterCapacity() && 
        this.minterTeamMintsMinted() + quant > this.minterTeamMintsCapacity()) {
      revert MaxSplaining ({
        reason: "Main:TM1"
      });
    }
    for (uint x = 0; x < quant;) {
      // mint it
      _mint(this.owner(), _nextUp());
      _oneTeamMint();
      unchecked { ++x; }
    }
  }

  function setTinys(
    address CA
  ) external
    onlyDev() {
    Tinys = CA;
  }

  function donate()
    external
    payable {
    // thank you
    emit ThankYou(msg.sender, msg.value);
  }

  // @notice: Function to receive ether, msg.data must be empty
  receive()
    external
    payable {
    emit PaymentReceived(msg.sender, msg.value);
  }

  // @notice: Function to receive ether, msg.data is not empty
  fallback()
    external
    payable {
    emit PaymentReceived(msg.sender, msg.value);
  }

  // @notice this is a public getter for ETH blance on contract
  function getBalance()
    external
    view
    returns (uint) {
    return address(this).balance;
  }

  // @notice will update _baseURI() by onlyDeveloper() role
  // @param _base: Base for NFT's
  function setBaseURI(
    string memory _base
    )
    public
    onlyDev() {
    string memory old = base;
    base = _base;
    emit UpdatedBaseURI(old, base);
  }

  // @notice: This override sets _base as the string for tokenURI(tokenId)
  function _baseURI()
    internal
    view
    override
    returns (string memory) {
    return base;
  }

  // @notice: This override is for making string/number now string/number.json
  // @param tokenId: tokenId to pull URI for
  function tokenURI(
    uint256 tokenId
  ) public
    view
    virtual
    override (ERC721)
    returns (string memory) {
    if (!_exists(tokenId)) {
      revert Unauthorized();
    }
    string memory baseURI = _baseURI();
    string memory json = ".json";
    return bytes(baseURI).length > 0 ? string(
                                         abi.encodePacked(
                                           baseURI
                                         , tokenId.toString()
                                         , json)
                                       ) : "";
  }

  // @notice: This override is to correct totalSupply()
  // @param tokenId: tokenId to burn
  function burn(
    uint256 tokenId
  ) public
    virtual
    override(ERC721Burnable) {
    //solhint-disable-next-line max-line-length
    if (!_isApprovedOrOwner(_msgSender(), tokenId)) {
      revert MaxSplaining({
        reason: "Main:B1"
      });
    }
    _burn(tokenId);
    // fixes totalSupply()
    _subOne();
  }

  // @notice: Standard override for ERC165
  // @param interfaceId: interfaceId to check for compliance
  // @return: bool if interfaceId is supported
  function supportsInterface(
    bytes4 interfaceId
  ) public
    view
    virtual
    override (
      ERC721
    , IERC165
    ) returns (bool) {
    return (
      interfaceId == type(IERC2981).interfaceId  ||
      interfaceId == type(EIP1412).interfaceId  ||
      super.supportsInterface(interfaceId)
    );
  }
}
