// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ticket} from "./Ticket.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract TicketFactory is Ownable {
    struct TicketData {
        address ticket;
        address verifier;
    }
    // ==============================
    // STATE VARIABLES
    // ==============================
    // this the trusted forwarder address of the sponspored tx component
    address public trustedForwarder;
    // this mapping stores
    mapping(uint256 => address) public tickets;
    // ticket count 
    uint256 public ticketCount;



    // ==============================
    // EVENTS
    // ==============================
    event TicketCreated(address indexed ticketAddress, string name, string symbol);



    constructor(address factoryOwner, address _trustedForwarder) Ownable(factoryOwner) {
        trustedForwarder = _trustedForwarder;
    }


    /**
     * @notice function is used to create a new ticket contract
     * @param owner this is the address of the ticket owner
     * @param name this is the name of the ticket
     * @param symbol this is the symbol of the ticket
     */
    function createNewTicket(
        address owner,
        string memory name,
        string memory symbol,
        IERC20 _paymentToken,
        uint40 _eventTime,
        uint40 _ticketMintCloseTime,
        uint256 _ticketPrice
    ) external returns (address) {
        Ticket ticket = new Ticket(
            owner, name, symbol, trustedForwarder, _paymentToken, _eventTime, _ticketMintCloseTime, _ticketPrice
        );

        tickets[ticketCount] = address(ticket);

        emit TicketCreated(address(ticket), name, symbol);
        ticketCount += 1;

        return address(ticket);
    }
}
