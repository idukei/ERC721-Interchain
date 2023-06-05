// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";

contract Boletos is ERC721Enumerable, Ownable {
    /**
     * @dev _baseTokenURI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`.
     */
    string _baseTokenURI;

    uint256 public _price = 0.01 ether;

    bool public _paused;

    uint256 public maxTokenIds = 20;// Max number of Boletokens

    // total number of tokenIds minted
    uint256 public tokenIds;

    // Whitelist contract instance
    IWhitelist whitelist;

    // boolean to keep track of when presale started
    bool public presaleStarted;

    // timestamp for even presale would end
    uint256 public presaleEnded;//Check from my-app / index.js

    modifier onlyWhenNotPaused {
        require(!_paused, "Contract currently paused");
        _;
    }

    /**
     * Constructor for Boletokens takes in the baseURI to set _baseTokenURI for the collection.
     * It also initializes an instance of whitelist interface.
     */
    constructor (string memory baseURI, address whitelistContract) ERC721("Boletokens", "BL") {
        _baseTokenURI = baseURI;
        whitelist = IWhitelist(whitelistContract);
    }

    /**
    * @dev startPresale starts a presale for the whitelisted addresses
     */
    function startPresale() public onlyOwner {
        presaleStarted = true;
        // Set presaleEnded time as current timestamp + 5 minutes
        presaleEnded = block.timestamp + 5 minutes;
    }

    /**
     * @dev presaleMint allows an user to mint one NFT per transaction during the presale. 
     */
    function presaleMint() public payable onlyWhenNotPaused {
        require(presaleStarted && block.timestamp < presaleEnded, "Presale is not running");
        require(whitelist.whitelistedAddresses(msg.sender), "You are not whitelisted");
        require(tokenIds < maxTokenIds, "Exceeded maximum supply");
        require(msg.value >= _price, "Ether sent is not correct");
        tokenIds += 1;
        
        _safeMint(msg.sender, tokenIds);
    }

    /**
    * @dev mint allows an user to mint 1 NFT per transaction after the presale has ended.
    */
    function mint() public payable onlyWhenNotPaused {
        require(presaleStarted && block.timestamp >=  presaleEnded, "Presale has not ended yet");
        require(tokenIds < maxTokenIds, "Exceed maximum supply");
        require(msg.value >= _price, "Ether sent is not correct");
        tokenIds += 1;
        _safeMint(msg.sender, tokenIds);
    }
    
    /**
    * @dev _baseURI overides the Openzeppelin's ERC721 implementation which by default
    * returned an empty string for the baseURI
    */
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }
     
    function setPaused(bool val) public onlyOwner {
        _paused = val;
    }
 
    /**
    * @dev Sends all the ether in the contract 
    * to the owner of the contract
     */
    function withdraw() public onlyOwner  {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) =  _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

     // Function to receive Ether. msg.data must be empty // receive the eth of the NFT sold
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}