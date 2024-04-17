// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";



contract Ticket is ERC721, ERC721URIStorage, Ownable, ERC2771Context {
    // ==============================
    // STATE VARIABLES 
    // ==============================
    uint256 public ticketPrice;
    uint40 public eventTime;
    uint40 public ticketMintClose;
    bool public isClosed;



    constructor(address initialOwner, string memory name, string memory symbol, address trustedForwarder)
        ERC721(name, symbol)
        Ownable(initialOwner)
        ERC2771Context(trustedForwarder)
    {}


    /**
     * 
     * @notice function ois used to mint ticket
     * @param to this is the address this ticket would be minted to
     * @param tokenId this is the token ID to be minted
     * @param uri this is the Metadata URL
     */
    function safeMint(address to, uint256 tokenId, string memory uri)
        public
        onlyOwner
    {
        require(!isClosed, "Ticket: Minting is closed");
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }


    /**
     * 
     * @param tokenId this is the tokenId would metadata is being queryed
     */
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }



    // fn set ticket price 
    // fn set ticket sales end 
    // fn set event time 
    // fn set is closed




    // =============================
    // INTERNAL FUNCTIONs
    // =============================
    function _msgSender() internal view virtual override(Context, ERC2771Context) returns (address) {
        return ERC2771Context._msgSender();
    }

    function _msgData() internal view virtual override(Context, ERC2771Context) returns (bytes calldata) {
        return ERC2771Context._msgData();
        
    }

    function _contextSuffixLength() internal view virtual override(Context, ERC2771Context) returns (uint256) {
        return 20;
    }
}