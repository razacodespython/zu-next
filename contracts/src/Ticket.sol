// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";

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
    // Total number of tickets minted
    uint256 public totalTicketsMinted;
    // This is the price for this ticket class
    uint256 public ticketPrice;


    // ==============================
    // EVENTS
    // ==============================
    event TicketMinted(address indexed to, uint256 tokenId, string uri);
    event TicketPriceChanged(uint256 newPrice);
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
        uint256 _ticketPrice,
        uint256 _ticketCap
    ) ERC721(name, symbol) Ownable(eventAdmin) ERC2771Context(trustedForwarder) {
        paymentToken = IERC20(_paymentToken);
        eventTime = _eventTime;

        // mint close time should be less than event time
        require(_ticketMintCloseTime < _eventTime, "Ticket: Invalid mint close time");
        ticketMintCloseTime = _ticketMintCloseTime;

        ticketPrice = _ticketPrice;
    }

    /**
     *
     * @notice function ois used to mint ticket
     * @param to this is the address this ticket would be minted to
     * @param tokenId this is the token ID to be minted
     * @param uri this is the Metadata URL
     */
    function purchaseTicket(address to, uint256 tokenId, string memory uri, address payer) public {
        require(!forceClosed, "Ticket: Minting is closed");
        require(block.timestamp < ticketMintCloseTime, "Ticket: Minting is closed");
        handlePayment(payer);
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        totalTicketsMinted += 1;

        emit TicketMinted(to, tokenId, uri);
    }

    /**
     *
     * @notice this function is used to mint ticket by an admin
     * @dev this function evades the `forceClosed` and `ticketMintCloseTime` checks
     * @param to this is the address this ticket would be minted to
     * @param tokenId this is the token ID to be minted
     * @param uri this is the Metadata URL
     */
    function adminMint(address to, uint256 tokenId, string memory uri) public onlyOwner {
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        totalTicketsMinted += 1;
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
    function setTicketPrice(uint256 _ticketPrice) public onlyOwner {
        ticketPrice = _ticketPrice;

        emit TicketPriceChanged(_ticketPrice);
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

    /**
     *
     * @notice this function is used to send generic token from this contract else else-where
     * @param recipent this is the address the balance would be sent to
     * @param token this is the address of the token to be sent
     * @param amount this is the amount of token to be sent
     */
    function withdrawGeneric(address recipent, address token, uint256 amount) public onlyOwner {
        IERC20(token).transfer(recipent, amount);

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
    function handlePayment(address payer) internal {
        paymentToken.transferFrom(payer, address(this), ticketPrice);
    }
}
