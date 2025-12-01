// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import { Test } from "forge-std/Test.sol";

import { EquilibriumBets } from "../src/contracts/EquilibriumBets.sol";
import { UsdcToken } from "./UsdcToken.sol";

contract EquilibriumBetsTest is Test {
    EquilibriumBets public equilibriumBets;
    UsdcToken public usdc;

    address public owner = makeAddr("owner");
    address public user1 = makeAddr("user1");
    address public user2 = makeAddr("user2");
    address public feeCollector = owner;

    uint256 public constant INITIAL_USDC = 10000e6;

    function setUp() public {
        usdc = new UsdcToken(address(this));

        bool success1 = usdc.transfer(user1, INITIAL_USDC);
        require(success1);
        bool success2 = usdc.transfer(user2, INITIAL_USDC);
        require(success2);
        bool success3 = usdc.transfer(owner, INITIAL_USDC);
        require(success3);

        equilibriumBets = new EquilibriumBets(owner, address(usdc), feeCollector);
    }

    function testDeposit() public {
        vm.startPrank(user1);

        usdc.approve(address(equilibriumBets), type(uint256).max);
        equilibriumBets.deposit(1000e6);

        vm.stopPrank();

        assertEq(usdc.balanceOf(user1), 9000e6);

        EquilibriumBets.UserBalance memory balance = equilibriumBets.getUserBalance(user1);

        assertEq(balance.total, 1000e6);
        assertEq(balance.locked, 0);
    }

    function testWithdraw() public {
        vm.startPrank(user1);

        usdc.approve(address(equilibriumBets), type(uint256).max);
        equilibriumBets.deposit(1000e6);

        assertEq(usdc.balanceOf(user1), 9000e6);

        equilibriumBets.withdraw(500e6);

        assertEq(usdc.balanceOf(user1), 9500e6);

        vm.stopPrank();

        EquilibriumBets.UserBalance memory balance = equilibriumBets.getUserBalance(user1);

        assertEq(balance.total, 500e6);
        assertEq(balance.locked, 0);
    }
}
