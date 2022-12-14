// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../Jungfrau.sol";
import "forge-std/Test.sol";

contract JungfrauTest is Test {
    Jungfrau public jungfrau;

    uint256 public constant AMOUNT = 1 * 10**18;

    function setUp() public {
        jungfrau = new Jungfrau();
    }

    function testOwnerCanMint() public {
        jungfrau.mint(address(this), AMOUNT);
        uint256 balance = jungfrau.balanceOf(address(this));
        assertEq(balance, AMOUNT);
    }
}
