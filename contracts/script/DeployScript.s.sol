// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;


import "forge-std/Script.sol";
import {TicketFactory} from "../src/TicketFactory.sol";
import {Ticket} from "../src/Ticket.sol";
import {TicketWithWhitelist} from "../src/TicketWithWhitelist.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


/// @dev this is a script used for deploying this ticketing system
contract DeployScript is Script {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address deployer = vm.addr(deployerPrivateKey);

    // this is the factory construction state variables
    address factoryOwner = vm.envAddress("FACTORY_OWNER");
    address factoryTrustedForwarder = vm.envAddress("FACTORY_TRUSTED_FORWARDER");
    address ticketTrustedForwarder = vm.envAddress("TICKET_TRUSTED_FORWARDER");

    function setUp() public {}

    function run() public {
        vm.startBroadcast(deployerPrivateKey);

        TicketFactory ticketFactory = new TicketFactory(factoryOwner, factoryTrustedForwarder, ticketTrustedForwarder);

        vm.stopBroadcast();
    }
}
