// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ticket} from "./Ticket.sol";
import "@openzeppelin/contracts/access/Ownable.sol";




contract TicketFactory is Ownable {
    address public trustedForwarder;


    constructor(address factoryOwner, address _trustedForwarder) Ownable(factoryOwner){
        trustedForwarder = _trustedForwarder;
    }



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