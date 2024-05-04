// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";



enum TicketFlavour {
    One,
    Two,
    Three,
    Four,
    Five,
    Six
}

contract Ticket is ERC721, ERC721URIStorage, Ownable, ERC2771Context {
    // ==============================
    // STATE VARIABLES
    // ==============================
    // this is the token used to pay for the ticket
    IERC20 public paymentToken;
    // this is the time the event would be holding
    uint40 public eventTime;
    // this is the time the ticket mint would be closed
    uint40 public ticketMintCloseTime;
    // mapping that indicates if a ticket has been used
    mapping(uint256 => bool) public usedTickets;
    // this is the state of the ticket minting
    bool public forceClosed;
    // Ticket flavour price [this is the price in wie the ticket would be going for]
    mapping(TicketFlavour => uint256) public ticketFlavourPrice;
    // Total number of tickets minted
    uint256 public totalTicketsMinted;
    /// Ticket flavour count
    uint256 public ticketFlavourCount;


    // ==============================
    // EVENTS
    // ==============================
    event TicketMinted(address indexed to, uint256 tokenId, string uri, TicketFlavour flavour);
    event TicketPriceChanged(uint256 newPrice, TicketFlavour flavour);
    event TicketMintCloseTimeChanged(uint40 newTime);
    event EventTimeChanged(uint40 newTime);
    event TicketSalesForceClosed(bool status);
    event Withdraw(address recipent);

    /**
     *
     * @param eventAdmin this is the address of the event admin
     * @param name this is the name of the ticket
     * @param symbol this is the TICKER symbol of the ticket
     * @param trustedForwarder this is the trusted forwarder address [responsilbe for sponsored txs]
     * @param _paymentToken this is the address of the token used to pay for the ticket
     * @param _eventTime this is the time stamp for the event
     * @param _ticketMintCloseTime this is the time the ticket mint would be closed
     * @param _ticketPrice this is the price of the ticket
     */
    constructor(
        address eventAdmin,
        string memory name,
        string memory symbol,
        address trustedForwarder,
        address _paymentToken,
        uint40 _eventTime,
        uint40 _ticketMintCloseTime,
        uint256[] memory _ticketPrice
    ) ERC721(name, symbol) Ownable(eventAdmin) ERC2771Context(trustedForwarder) {
        paymentToken = IERC20(_paymentToken);
        eventTime = _eventTime;

        // mint close time should be less than event time
        require(_ticketMintCloseTime < _eventTime, "Ticket: Invalid mint close time");
        ticketMintCloseTime = _ticketMintCloseTime;

        // ensure the length of the ticket price is equal to the length of the TicketFlavour enum
        require(_ticketPrice.length <= 6, "Ticket: Invalid ticket price length");
        
        for (uint256 i = 0; i < _ticketPrice.length; i++) {
            ticketFlavourPrice[TicketFlavour(i)] = _ticketPrice[i];
        }

        ticketFlavourCount = _ticketPrice.length;
    }

    /**
     *
     * @notice function ois used to mint ticket
     * @param to this is the address this ticket would be minted to
     * @param tokenId this is the token ID to be minted
     * @param uri this is the Metadata URL
     */
    function purchaseTicket(address to, uint256 tokenId, string memory uri, address payer, TicketFlavour flavour) public {
        require(!forceClosed, "Ticket: Minting is closed");
        require(block.timestamp < ticketMintCloseTime, "Ticket: Minting is closed");
        handlePayment(payer, flavour);
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        totalTicketsMinted += 1;

        emit TicketMinted(to, tokenId, uri, flavour);
    }

    /**
     *
     * @notice this function is used to check if a ticket has been used
     * @param tokenId this is the tokenId to be checked
     */
    function useTicket(uint256 tokenId) public {
        require(ownerOf(tokenId) == _msgSender(), "Ticket: caller is not the owner of the ticket");
        usedTickets[tokenId] = true;
    }

    /**
     *
     * @param tokenId this is the tokenId would metadata is being queryed
     */
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     *
     * @notice this function is used to set the price this ticket can be purchased at
     * @param _ticketPrice this is the price of the ticket
     */
    function setTicketPrice(uint256 _ticketPrice, TicketFlavour flavour) public onlyOwner {
        ticketFlavourPrice[flavour] = _ticketPrice;

        emit TicketPriceChanged(_ticketPrice, flavour);
    }

    /**
     *
     * @notice this function is used to set the time the ticket purchase should halt
     * @param _ticketMintCloseTime this is the timestamp the ticket mint should be closed
     */
    function setTicketMintCloseTime(uint40 _ticketMintCloseTime) public onlyOwner {
        require(_ticketMintCloseTime < eventTime, "Ticket: Invalid mint close time");
        ticketMintCloseTime = _ticketMintCloseTime;

        emit TicketMintCloseTimeChanged(_ticketMintCloseTime);
    }

    /**
     *
     * @notice this function would be used to set the time this event would holding
     * @param _eventTime this is the time the event would be holding
     */
    function setEventTime(uint40 _eventTime) public onlyOwner {
        require(_eventTime > ticketMintCloseTime, "Ticket: Invalid event time");
        eventTime = _eventTime;

        emit EventTimeChanged(_eventTime);
    }

    /**
     *
     * @notice this function is used by an admin to close the ticket minting
     * @param status this is the new state of `forceClosed`
     */
    function forceToggleTicketSales(bool status) public onlyOwner {
        forceClosed = status;

        emit TicketSalesForceClosed(status);
    }

    /**
     *
     * @notice this function is used to withdraw the balance of the contract
     * @param recipent this is the address the balance would be sent to
     */
    function withdraw(address recipent) public onlyOwner {
        paymentToken.transfer(recipent, paymentToken.balanceOf(address(this)));

        emit Withdraw(recipent);
    }

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

    /**
     *
     * @dev this function is used to debit ERC20 token from a `payer`, the amount debitted is the current ticket price
     * @param payer this is the address paying for ticket
     */
    function handlePayment(address payer, TicketFlavour flavour) internal {
        paymentToken.transferFrom(payer, address(this), ticketFlavourPrice[flavour]);
    }
}
