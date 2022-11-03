// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@solmate/tokens/ERC20.sol";
import "@solmate/auth/Owned.sol";

/**
 * LONG LIVE THE PIRATES! DEATH TO EIGER!
 */
contract Jungfrau is ERC20("Jungfrau", "JFR", 18), Owned(msg.sender) {
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
