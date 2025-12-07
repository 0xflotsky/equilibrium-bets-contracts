// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.31;

import { Admin } from "./Admin.sol";
import { Vault } from "./Vault.sol";

contract EquilibriumBets is Vault {
    constructor(address owner, address usdc, address feeCollector) Vault(owner, usdc, feeCollector) {}
}
