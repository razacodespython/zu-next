// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ticket} from "./Ticket.sol";
import {TicketWithWhitelist} from "./TicketWithWhitelist.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";

struct Event {
    // this is the address of all the ticket classes
    address[] tickets;
    // this is that address of the verifier contract
    address[] verifier;
    // this is the addressof the owner
    address owner;
    // this is the name of the event
    string name;
    // this is the symbol of the event
    string symbol;
    // this is the time the event would be holding
    uint40 eventTime;
}

contract TicketFactory is Ownable, ERC2771Context {
    // ==============================
    // STATE VARIABLES
    // ==============================
    // this the trusted forwarder address of the sponspored tx component
    address public ticketTrustedForwarder;
    // this mapping stores this event_id to the event struct
    mapping(uint256 => Event) public events;
    // event count
    uint256 public eventCount;

    // ==============================
    // EVENTS
    // ==============================
    event EventCreated(uint256 indexed eventId, address indexed owner, string symbol);
    event TicketCreated(uint256 indexed eventId, string symbol);
    event VerifierContractSet(uint256 indexed ticket, address[] verifier);

    constructor(address factoryOwner, address _trustedForwarder, address _ticketTrustedForwarder)
        Ownable(factoryOwner)
        ERC2771Context(_trustedForwarder)
    {
        ticketTrustedForwarder = _ticketTrustedForwarder;
    }

    /**
     * @notice function is used to create a new event
     * @param owner this is the address of the event owner
     * @param name this is the name of the event
     * @param symbol this is the symbol of the event
     * @param _eventTime this is the time the event would be holding
     */
    function createEvent(address owner, string memory name, string memory symbol, uint40 _eventTime)
        external
        returns (uint256)
    {
        uint256 eventId = eventCount;
        Event memory newEvent = Event({
            tickets: new address[](0),
            verifier: new address[](0),
            owner: owner,
            name: name,
            symbol: symbol,
            eventTime: _eventTime
        });

        events[eventId] = newEvent;
        eventCount += 1;

        emit EventCreated(eventId, owner, symbol);

        return eventId;
    }

    /**
     * @notice function is used to create a new ticket contract
     * @param eventId this is the ID of the event
     * @param _paymentToken this is the address of the token used to pay for the ticket
     * @param _ticketMintCloseTime this is the time the ticket mint would be closed
     * @param _ticketPrice this is the price of the ticket
     * @param _whitelist this is the list of addresses that can mint the ticket
     */
    function createNewTicket(
        uint256 eventId,
        string memory _ticketName,
        address _paymentToken,
        uint40 _ticketMintCloseTime,
        uint256 _ticketPrice,
        uint256 _ticketCap,
        address[] memory _whitelist
    ) external returns (address) {
        require(events[eventId].owner == _msgSender(), "TicketFactory: caller is not the event owner");
        require(_ticketMintCloseTime < events[eventId].eventTime, "TicketFactory: Invalid mint close time");

        address newTicket;

        if (_whitelist.length > 0) {
            newTicket = address(
                new TicketWithWhitelist(
                    events[eventId].owner,
                    _ticketName,
                    events[eventId].symbol,
                    ticketTrustedForwarder,
                    _paymentToken,
                    events[eventId].eventTime,
                    _ticketMintCloseTime,
                    _ticketPrice,
                    _ticketCap,
                    _whitelist
                )
            );
        } else {
            newTicket = address(
                new Ticket(
                    events[eventId].owner,
                    _ticketName,
                    events[eventId].symbol,
                    ticketTrustedForwarder,
                    _paymentToken,
                    events[eventId].eventTime,
                    _ticketMintCloseTime,
                    _ticketPrice,
                    _ticketCap
                )
            );
        }

        events[eventId].tickets.push(address(newTicket));
        emit TicketCreated(eventId, events[eventId].symbol);
        return address(newTicket);
    }

    /**
     * @notice function is used to set the verifier contract for a ticket
     * @param eventId this is the ID of the ticket
     * @param verifier this is the address of the verifier contract
     */
    function setVerificationContract(uint256 eventId, address[] memory verifier) external {
        require(events[eventId].owner == _msgSender(), "TicketFactory: caller is not the ticket owner");
        events[eventId].verifier = verifier;

        emit VerifierContractSet(eventId, verifier);
    }

    /**
     * @notice function sets the trusted forwarder address
     * @param _ticketTrustedForwarder address of the new trusted forwarder
     */
    function setTrustedForwarder(address _ticketTrustedForwarder) external onlyOwner {
        ticketTrustedForwarder = _ticketTrustedForwarder;
    }

    /**
     * @notice function is used by the event admin to change the owner of the event
     * @param eventId this is the ID of the event
     * @param newOwner this is the address of the new owner
     */
    function changeEventOwner(uint256 eventId, address newOwner) public {
        require(events[eventId].owner == _msgSender(), "TicketFactory: caller is not the event owner");
        events[eventId].owner = newOwner;
    }

    /**
     * @notice function is used to get the tickets for an event
     * @param eventId this is the ID of the event
     */
    function getTickets(uint256 eventId) public view returns (address[] memory) {
        return events[eventId].tickets;
    }

    /**
     * @notice function is used to get the verifier for a ticket
     * @param eventId this is the ID of the event
     */
    function getVerifier(uint256 eventId) public view returns (address[] memory) {
        return events[eventId].verifier;
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
}

// TESTNET DEPLOYMENT: 0x7a38630137f22de9c11fd67c997751b608899c81
