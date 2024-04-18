// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ticket} from "./Ticket.sol";
import "@openzeppelin/contracts/access/Ownable.sol";




contract TicketFactory is Ownable {
    // this the trusted forwarder address of the sponspored tx component
    address public trustedForwarder;

    constructor(address factoryOwner, address _trustedForwarder) Ownable(factoryOwner){
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
        string memory symbol
    ) external returns (address ) {
        Ticket ticket = new Ticket(
            owner,
            name,
            symbol,
            trustedForwarder
        );

        return address(ticket);
    }
}