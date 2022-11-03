// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@solmate/tokens/ERC20.sol";
import "@solmate/auth/Owned.sol";

contract Blemflarck is ERC20("Blemflarck", "BFK", 18), Owned(msg.sender) {
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
