// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.31;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract UsdcToken is ERC20 {
    constructor(address recipient) ERC20("USDC Token", "USDC") {
        _mint(recipient, 1000000 * 10 ** decimals());
    }
}
