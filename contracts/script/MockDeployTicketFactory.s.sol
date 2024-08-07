// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {TicketFactory} from "../src/TicketFactory.sol";
import {Ticket} from "../src/Ticket.sol";
import {TicketWithWhitelist} from "../src/TicketWithWhitelist.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployFactoryScript is Script {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address owner = vm.addr(deployerPrivateKey);

    function setUp() public {}

    function run() public {
        vm.startBroadcast(deployerPrivateKey);

        TicketFactory ticketFactory = new TicketFactory(owner, address(0), address(0));
        Ticket ticket = new Ticket(owner, "TicketWithClass", "TWC", address(0), address(0), 2, 0, 0);
        address[] memory whitelist = new address[](1);
        whitelist[0] = address(0);
        TicketWithWhitelist ticketWithWhitelist =
            new TicketWithWhitelist(owner, "TicketWithWhitelist", "TWW", address(0), address(0), 2, 0, 0, whitelist);

        vm.stopBroadcast();
    }
}
