// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.31;

import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { Admin } from "./Admin.sol";

contract Vault is Admin, ReentrancyGuard {
    using SafeERC20 for IERC20;

    event Deposit(address indexed from, uint256 amount);
    event Withdrawal(address indexed to, uint256 amount);

    error AmountIsLessThanAvailableAmount(uint256 amount, uint256 availableAmount);
    error AmountIsLessThanMinDepositAmount(uint256 amount, uint256 minDepositAmount);
    error AmountIsZero();

    struct UserBalance {
        uint256 total;
        uint256 locked;
    }

    mapping(address => UserBalance) private balances;

    IERC20 usdc;

    modifier notZeroAmount(uint256 amount) {
        _notZeroAmount(amount);
        _;
    }

    constructor(address owner, address _usdc, address feeCollector) Admin(owner, feeCollector) {
        usdc = IERC20(_usdc);
    }

    /**
     * @notice Deposits USDC tokens to the contract. Requires approval
     * @param amount amount of USDC
     */
    function deposit(uint256 amount) external nonReentrant notZeroAmount(amount) {
        if (amount < MIN_DEPOSIT_USDC_AMOUNT) revert AmountIsLessThanMinDepositAmount(amount, MIN_DEPOSIT_USDC_AMOUNT);

        usdc.safeTransferFrom(msg.sender, address(this), amount);
        balances[msg.sender].total += amount;

        emit Deposit(msg.sender, amount);
    }

    /**
     * @notice Withdraws available USDC tokens from the contract
     * @param amount amount of USDC
     */
    function withdraw(uint256 amount) external nonReentrant notZeroAmount(amount) {
        uint availableAmount = balances[msg.sender].total - balances[msg.sender].locked;
        if (!(amount <= availableAmount)) revert AmountIsLessThanAvailableAmount(amount, availableAmount);

        usdc.safeTransfer(msg.sender, amount);
        balances[msg.sender].total -= amount;

        emit Withdrawal(msg.sender, amount);
    }

    function _notZeroAmount(uint256 amount) private pure {
        if (amount <= 0) revert AmountIsZero();
    }
}
