// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "forge-std/Test.sol";
import {Ticket} from "../src/Ticket.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestPaymentToken is ERC20 {
    constructor(address owner) ERC20("TestPaymentToken", "TPT") {
        _mint(owner, 1000000 ether);
    }
}

contract TicketTest is Test {
    TestPaymentToken paymentToken;
    Ticket ticket;
    address owner = address(0x123);
    address user = address(0x456);

    function setUp() public {
        paymentToken = new TestPaymentToken(user);
        ticket = new Ticket(
            owner,
            "Events Ticket",
            "EVT",
            address(0),
            address(paymentToken),
            uint40(block.timestamp + 1000),
            uint40(block.timestamp + 500),
            50 ether
        );
    }

    function testPurchaseTicket() public {
        vm.startPrank(user);
        paymentToken.approve(address(ticket), 50 ether);

        ticket.purchaseTicket(user, "https://example.com", user);

        assertEq(paymentToken.balanceOf(user), 999950 ether);
        assertEq(paymentToken.balanceOf(address(ticket)), 50 ether);
        assertEq(ticket.balanceOf(user), 1);
        assertEq(ticket.totalTicketsMinted(), 1);
        assertEq(ticket.tokenURI(0), "https://example.com");
    }

    function testPurchaseTicket_forcedClosed() public {
        vm.startPrank(user);
        paymentToken.approve(address(ticket), 50 ether);

        vm.startPrank(owner);
        ticket.forceToggleTicketSales(true);

        // expect to revert with "Ticket sales has been closed"
        vm.expectRevert("Ticket: Minting is closed");

        vm.startPrank(user);
        ticket.purchaseTicket(owner, "https://example.com", user);
    }

    function testPurchaseTicket_mintCloseTime() public {
        vm.startPrank(user);
        paymentToken.approve(address(ticket), 50 ether);

        vm.warp(block.timestamp + 1001);

        // expect to revert with "Ticket sales has been closed"
        vm.expectRevert("Ticket: Minting is closed");

        vm.startPrank(user);
        ticket.purchaseTicket(owner, "https://example.com", user);
    }

    function testAdminMint() public {
        testPurchaseTicket();

        vm.startPrank(owner);
        ticket.adminMint(user, "https://example.com");

        assertEq(ticket.balanceOf(user), 2);
        assertEq(ticket.totalTicketsMinted(), 2);
        assertEq(ticket.tokenURI(0), "https://example.com");
    }

    function testAdminMint_notAdmin() public {
        // expect to revert with "Ownable: caller is not the owner"
        vm.expectRevert();

        vm.startPrank(user);
        ticket.adminMint(user, "https://example.com");
    }
}
