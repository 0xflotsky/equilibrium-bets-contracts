// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.31;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract Admin is Ownable {
    uint16 public constant MAX_FEE_BPS = 500;
    uint32 public constant MIN_DEPOSIT_USDC_AMOUNT = 10e6;

    enum Outcome {
        OutcomeA,
        OutcomeB,
        OtherOutcome
    }

    enum Status {
        Active,
        Resolved,
        Cancelled
    }

    address private feeCollector;
    uint16 public feeBps;

    constructor(address owner, address _feeCollector) Ownable(owner) {
        feeCollector = _feeCollector;
    }

    function setFeeCollector(address newFeeCollector) external onlyOwner {
        feeCollector = newFeeCollector;
    }

    function setFeeBps(uint16 newFeeBps) external onlyOwner {
        if (newFeeBps >= MAX_FEE_BPS) {
            feeBps = MAX_FEE_BPS;
        }

        feeBps = newFeeBps;
    }

    function createEvent() external onlyOwner {}
    function resolveEvent() external {}
    function removeEvent() external onlyOwner {}
}
