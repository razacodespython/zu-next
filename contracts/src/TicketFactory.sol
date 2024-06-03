// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {TicketWithClass} from "./TicketWithClass.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


struct TicketData {
    // this is the address of all the ticket classes
    address[] ticketClasses;
    // this is that address of the verifier contract
    address verifier;
    // this is the addressof the owner
    address owner;

}

contract TicketFactory is Ownable {
    // ==============================
    // STATE VARIABLES
    // ==============================
    // this the trusted forwarder address of the sponspored tx component
    address public trustedForwarder;
    // this mapping stores
    mapping(uint256 => TicketData) public tickets;
    // ticket count 
    uint256 public ticketCount;



    // ==============================
    // EVENTS
    // ==============================
    event TicketCreated(uint256 indexed eventId, string symbol);
    event VerifierContractSet(uint256 indexed ticket, address verifier);



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
        address _paymentToken,
        uint40 _eventTime,
        uint40 _ticketMintCloseTime,
        uint256[] memory _ticketPrice
    ) external returns (address[] memory) {
        uint256 eventId = ticketCount;

        for (uint256 i = 0; i < _ticketPrice.length; i++) {
            require(_ticketPrice[i] > 0, "TicketFactory: ticket price must be greater than 0");

            TicketWithClass ticket = new TicketWithClass(
                owner, name, symbol, trustedForwarder, _paymentToken, _eventTime, _ticketMintCloseTime, _ticketPrice[i]
            );

            tickets[eventId].ticketClasses.push(address(ticket));
        }
        
        ticketCount += 1;
        tickets[eventId].owner = owner;
        
        emit TicketCreated(eventId, symbol);
        
        return tickets[eventId].ticketClasses;
    }

    /**
     * @notice function is used to set the verifier contract for a ticket
     * @param eventId this is the ID of the ticket
     * @param verifier this is the address of the verifier contract
     */
    function setVerificationContract(uint256 eventId, address verifier) external {
        address ticketOwner = tickets[eventId].owner;
        require(ticketOwner == msg.sender, "TicketFactory: caller is not the ticket owner");
        tickets[eventId].verifier = verifier;

        emit VerifierContractSet(eventId, verifier);
    }

    /**
     * @notice function sets the trusted forwarder address
     * @param _trustedForwarder address of the new trusted forwarder
     */
    function setTrustedForwarder(address _trustedForwarder) external onlyOwner {
        trustedForwarder = _trustedForwarder;
    }
}



// TESTNET DEPLOYMENT: 0x7a38630137f22de9c11fd67c997751b608899c81