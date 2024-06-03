// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {TicketFactory} from "../src/TicketFactory.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract DeployFactoryScript is Script {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address owner = vm.addr(deployerPrivateKey);

    // function setUp() public {}

    function run() public {
        vm.startBroadcast(deployerPrivateKey);

        TicketFactory ticketFactory = new TicketFactory(owner, address(0));

        vm.stopBroadcast();
    }
}
