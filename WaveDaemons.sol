/***

*  _       __                 ____                                       
* | |     / /___ __   _____  / __ \____ ____  ____ ___  ____  ____  _____
* | | /| / / __ `/ | / / _ \/ / / / __ `/ _ \/ __ `__ \/ __ \/ __ \/ ___/
* | |/ |/ / /_/ /| |/ /  __/ /_/ / /_/ /  __/ / / / / / /_/ / / / (__  ) 
* |__/|__/\__,_/ |___/\___/_____/\__,_/\___/_/ /_/ /_/\____/_/ /_/____/  
                                                                       

 * Forked shoddily by LuckyLuciano of BitDaemons & the DaemonDAO
 * https://github.com/daemondao | https://twitter.com/luciano_nft | https://bitdaemons.space/
 
 * OG contract by DaemonDev MaxFlowO2 (https://github.com/MaxflowO2 | https://twitter.com/MaxflowO2)
 *
 * 
 * Project: WaveDaemons
 * URI: pending
 */

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/introspection/ERC165Storage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./access/Developer.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./ERC2981Collection.sol";
import "./interface/IMAX721.sol";
import "./modules/PaymentSplitter.sol";

contract WaveDaemons is ERC721, ERC2981Collection, IMAX721, ERC165Storage, PaymentSplitter, Developer, Ownable {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIdCounter;
  Counters.Counter private _teamMintCounter;
  uint256 private mintFees;
  uint256 private mintSize;
  uint256 private teamMintSize;
  string private base;
  bool private enableMinter;

  event UpdatedBaseURI(string _old, string _new);
  event UpdatedMintFees(uint256 _old, uint256 _new);
  event UpdatedMintSize(uint256 _old, uint256 _new);
  event UpdatedMintStatus(bool _old, bool _new);
  event UpdatedRoyalties(address newRoyaltyAddress, uint256 newPercentage);
  event UpdatedTeamMintSize(uint256 _old, uint256 _new);

  // bytes4 constants for ERC165
  bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;
  bytes4 private constant _INTERFACE_ID_IERC2981 = 0x2a55205a;
  bytes4 private constant _INTERFACE_ID_ERC2981Collection = 0x6af56a00;
  bytes4 private constant _INTERFACE_ID_IMAX721 = 0x18160ddd;
  bytes4 private constant _INTERFACE_ID_Developer = 0x538a50ce;
  bytes4 private constant _INTERFACE_ID_PaymentSplitter = 0x20998aed;

  constructor() ERC721("WaveDaemons", "WAVEDMN") {

    // ECR165 Interfaces Supported
    _registerInterface(_INTERFACE_ID_ERC721);
    _registerInterface(_INTERFACE_ID_IERC2981);
    _registerInterface(_INTERFACE_ID_ERC2981Collection);
    _registerInterface(_INTERFACE_ID_IMAX721);
    _registerInterface(_INTERFACE_ID_Developer);
    _registerInterface(_INTERFACE_ID_PaymentSplitter);
  }

/***
 *    ███╗   ███╗██╗███╗   ██╗████████╗
 *    ████╗ ████║██║████╗  ██║╚══██╔══╝
 *    ██╔████╔██║██║██╔██╗ ██║   ██║   
 *    ██║╚██╔╝██║██║██║╚██╗██║   ██║   
 *    ██║ ╚═╝ ██║██║██║ ╚████║   ██║   
 *    ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝   ╚═╝   
 */ 

  function publicMint(uint256 amount) public payable {
    require(enableMinter, "Minter not active");
    require(msg.value == mintFees * amount, "Wrong amount of Native Token");
    require(_tokenIdCounter.current() + amount < mintSize, "Can not mint that many");
    // Send payment line
    for (uint i = 0; i < amount; i++) {
      _safeMint(msg.sender, _tokenIdCounter.current());
      _tokenIdCounter.increment();
    }
  }
  
  /**
 *To burn TinyDaemons ERC721 NFT tokens, you must first approve the WaveDaemons contract address in the NFT contract, using setApprovalForAll bool True
 */
  
  function burn2Mint(uint256[] calldata tokenIds) external {
    //THE REQUIREMENTS
    require(enableMinter, "Minter not active");
    require(_tokenIdCounter.current() + 1 < mintSize, "Can not mint that many");
    require(tokenIds.length == 5, "YOU MUST SACRIFICE 5 TINYS COWARD");
    
    //THE BURN
    
    for (uint256 i = 0; i < tokenIds.length; i++) {
      IERC721 erc721 = IERC721(nftcollection);
      erc721.safeTransferFrom(msg.sender, 0x000000000000000000000000000000000000dead, tokenIds[i]);
        }
    //THE MINT
    _safeMint(msg.sender, _tokenIdCounter.current());
    _tokenIdCounter.increment();
    
  }
    
    

  function teamMint(address _address) public onlyOwner {
    require(teamMintSize != 0, "Team minting not enabled");
    require(_tokenIdCounter.current() < mintSize, "Can not mint that many");
    require(_teamMintCounter.current() < teamMintSize, "Can not team mint anymore");
    _safeMint(_address, _tokenIdCounter.current());
    _tokenIdCounter.increment();
    _teamMintCounter.increment();
  }

  // Function to receive ether, msg.data must be empty
  receive() external payable {
    // From PaymentSplitter.sol
    emit PaymentReceived(msg.sender, msg.value);
  }

  // Function to receive ether, msg.data is not empty
  fallback() external payable {
    // From PaymentSplitter.sol
    emit PaymentReceived(msg.sender, msg.value);
  }

  function getBalance() external view returns (uint) {
    return address(this).balance;
  }

/***
 *     ██████╗ ██╗    ██╗███╗   ██╗███████╗██████╗ 
 *    ██╔═══██╗██║    ██║████╗  ██║██╔════╝██╔══██╗
 *    ██║   ██║██║ █╗ ██║██╔██╗ ██║█████╗  ██████╔╝
 *    ██║   ██║██║███╗██║██║╚██╗██║██╔══╝  ██╔══██╗
 *    ╚██████╔╝╚███╔███╔╝██║ ╚████║███████╗██║  ██║
 *     ╚═════╝  ╚══╝╚══╝ ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝
 * This section will have all the internals set to onlyOwner
 */

  // @notice this will use internal functions to set EIP 2981
  // found in IERC2981.sol and used by ERC2981Collections.sol
  function setRoyaltyInfo(address _royaltyAddress, uint256 _percentage) public onlyOwner {
    _setRoyalties(_royaltyAddress, _percentage);
    emit UpdatedRoyalties(_royaltyAddress, _percentage);
  }

  // @notice this will set the fees required to mint using
  // publicMint(), must enter in wei. So 1 ETH = 10**18.
  // updated to ETH (this case FTM)
  function setMintFees(uint256 _newFee) public onlyOwner {
    uint256 oldFee = mintFees;
    mintFees = _newFee * 10**18;
    emit UpdatedMintFees(oldFee, mintFees);
  }

  // @notice this will enable publicMint()
  function enableMinting() public onlyOwner {
    bool old = enableMinter;
    enableMinter = true;
    emit UpdatedMintStatus(old, enableMinter);
  }

  // @notice this will disable publicMint()
  function disableMinting() public onlyOwner {
    bool old = enableMinter;
    enableMinter = false;
    emit UpdatedMintStatus(old, enableMinter);
  }

/***
 *    ██████╗ ███████╗██╗   ██╗
 *    ██╔══██╗██╔════╝██║   ██║
 *    ██║  ██║█████╗  ██║   ██║
 *    ██║  ██║██╔══╝  ╚██╗ ██╔╝
 *    ██████╔╝███████╗ ╚████╔╝ 
 *    ╚═════╝ ╚══════╝  ╚═══╝  
 * This section will have all the internals set to onlyDev
 * also contains all overrides required for funtionality
 */

  // @notice will update _baseURI() by onlyDev role
  function setBaseURI(string memory _base) public onlyDev {
    string memory old = base;
    base = _base;
    emit UpdatedBaseURI(old, base);
  }

  // @notice will set "team minting" by onlyDev role
  function setTeamMinting(uint256 _amount) public onlyDev {
    uint256 old = teamMintSize;
    teamMintSize = _amount;
    emit UpdatedTeamMintSize(old, teamMintSize);
  }

  // @notice will set mint size by onlyDev role
  function setMintSize(uint256 _amount) public onlyDev {
    uint256 old = mintSize;
    mintSize = _amount;
    emit UpdatedMintSize(old, mintSize);
  }

  // @notice will add an address to PaymentSplitter by onlyDev role
  function addPayee(address addy, uint256 shares) public onlyDev {
    _addPayee(addy, shares);
  }

  // @notice function useful for accidental ETH transfers to contract (to user address)
  // wraps _user in payable to fix address -> address payable
  function sweepEthToAddress(address _user, uint256 _amount) public onlyDev {
    payable(_user).transfer(_amount);
  }

  ///
  /// Developer, these are the overrides
  ///

  // @notice solidity required override for _baseURI()
  function _baseURI() internal view override returns (string memory) {
    return base;
  }

  // @notice solidity required override for supportsInterface(bytes4)
  function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC165Storage, IERC165) returns (bool) {
    return super.supportsInterface(interfaceId);
  }

  // @notice will return status of Minter
  function minterStatus() external view override(IMAX721) returns (bool) {
    return enableMinter;
  }

  // @notice will return minting fees
  function minterFees() external view override(IMAX721) returns (uint256) {
    return mintFees;
  }

  // @notice will return maximum mint capacity
  function minterMaximumCapacity() external view override(IMAX721) returns (uint256) {
    return mintSize;
  }

  // @notice will return maximum "team minting" capacity
  function minterMaximumTeamMints() external view override(IMAX721) returns (uint256) {
    return teamMintSize;
  }
  // @notice will return "team mints" left
  function minterTeamMintsRemaining() external view override(IMAX721) returns (uint256) {
    return teamMintSize - _teamMintCounter.current();
  }

  // @notice will return "team mints" count
  function minterTeamMintsCount() external view override(IMAX721) returns (uint256) {
    return _teamMintCounter.current();
  }

  // @notice will return current token count
  function totalSupply() external view override(IMAX721) returns (uint256) {
    return _tokenIdCounter.current();
  }
}
