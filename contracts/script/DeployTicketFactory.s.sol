// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {TicketFactory, Ticket} from "../src/TicketFactory.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract DeployFactoryScript is Script {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address owner = vm.addr(deployerPrivateKey);

    // function setUp() public {}

    function run() public {
        vm.startBroadcast(deployerPrivateKey);

        TicketFactory ticketFactory = new TicketFactory(owner, address(0));
        uint256[] memory ticketFlavourPrices = new uint256[](3);
        ticketFlavourPrices[0] = 1000000000000000000;
        ticketFlavourPrices[1] = 2000000000000000000;
        ticketFlavourPrices[2] = 3000000000000000000;

        Ticket ticket = new Ticket(address(1), "name", "symbol", address(0), address(0), 50, 25, ticketFlavourPrices);

        vm.stopBroadcast();
    }
}
