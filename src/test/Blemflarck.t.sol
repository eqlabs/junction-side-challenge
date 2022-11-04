// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../Blemflarck.sol";
import "forge-std/Test.sol";

contract BlemflarckTest is Test {
    Blemflarck public blemflarck;

    uint256 public constant AMOUNT = 42 * 10**18;

    function setUp() public {
        blemflarck = new Blemflarck();
    }

    function testOwnerCanMint() public {
        blemflarck.mint(address(this), AMOUNT);
        uint256 balance = blemflarck.balanceOf(address(this));
        assertEq(balance, AMOUNT);
    }
}
