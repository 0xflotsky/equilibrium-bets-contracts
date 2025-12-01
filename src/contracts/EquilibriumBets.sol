// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract EquilibriumBets is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    event Deposit(address indexed from, uint256 amount);
    event Withdrawal(address indexed to, uint256 amount);

    IERC20 usdc;

    address private feeCollectorAddress;

    struct UserBalance {
        uint256 total;
        uint256 locked;
    }

    mapping(address => UserBalance) private balances;

    modifier notZeroAmount(uint256 amount) {
        _notZeroAmount(amount);
        _;
    }

    constructor(address owner, address usdcTokenAddress, address _feeCollectorAddress) Ownable(owner) {
        usdc = IERC20(usdcTokenAddress);
        feeCollectorAddress = _feeCollectorAddress;
    }

    function approve(uint256 amount) external {
        usdc.approve(address(this), amount);
    }

    function deposit(uint256 amount) external nonReentrant notZeroAmount(amount) {
        require(amount >= 10e6, "Minimum deposited amount is 10 USDC");

        usdc.safeTransferFrom(msg.sender, address(this), amount);
        balances[msg.sender].total += amount;

        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint256 amount) external nonReentrant notZeroAmount(amount) {
        require(
            amount <= balances[msg.sender].total - balances[msg.sender].locked,
            "Can't withdraw more than available"
        );

        usdc.safeTransfer(msg.sender, amount);
        balances[msg.sender].total -= amount;

        emit Withdrawal(msg.sender, amount);
    }

    function getUserBalance(address user) external view returns (UserBalance memory) {
        return balances[user];
    }

    function setFeeCollectorAddress(address newFeeCollectorAddress) external onlyOwner {
        feeCollectorAddress = newFeeCollectorAddress;
    }

    function _notZeroAmount(uint256 amount) private pure {
        require(amount > 0, "Amount must be greater than 0");
    }
}
