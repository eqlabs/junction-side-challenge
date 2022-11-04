// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@solmate/tokens/ERC20.sol";
import "@solmate/auth/Owned.sol";

/**
 * LONG LIVE THE PIRATES! DEATH TO EIGER!
 */
contract Jungfrau is ERC20("Jungfrau", "JFR", 18), Owned(msg.sender) {
    uint256 public constant MAX_MINT_AMOUNT = 128 * 10**18;

    function mint(address to, uint256 amount) external {
        require(
            this.balanceOf(to) + amount < MAX_MINT_AMOUNT,
            "Nobody needs more than 128 Jungfrau. DEATH TO EIGER!"
        );
        _mint(to, amount);
    }
}
