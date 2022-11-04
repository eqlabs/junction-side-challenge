// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/Blemflarck.sol";
import "../src/Jungfrau.sol";
import "../src/BFKLoanMarket.sol";

contract MyScript is Script {
    uint256 public constant AMOUNT = 42 * 10**18;

    function run() external {
        //uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address exploiter = 0x08A2DE6F3528319123b25935C92888B16db8913E;
        address deployer = 0x02B2017c737aDC3DbAaA77bE0897A0EA76d87d4c;

        // Deploy the token contracts with the deployer key that isn't compromised
        vm.startBroadcast();

        Blemflarck blemflarck = new Blemflarck();
        Jungfrau jungfrau = new Jungfrau();

        // Fund this deploy address with blemflarck as collateral
        blemflarck.mint(msg.sender, AMOUNT);

        // Deploy the loan contract with the compromised key
        address eurusdOracle = 0x7d7356bF6Ee5CDeC22B216581E48eCC700D0497A;

        BFKLoanMarket bfkLoanMarket = new BFKLoanMarket(
            address(blemflarck),
            address(jungfrau),
            eurusdOracle
        );
        bfkLoanMarket.setOwner(exploiter);

        // Fund the bfkLoanMarket with loanable jungfrau
        jungfrau.mint(address(bfkLoanMarket), AMOUNT * 2);

        // Take the loan against blemflarck
        blemflarck.approve(address(bfkLoanMarket), AMOUNT);
        bfkLoanMarket.loan(AMOUNT);
        vm.stopBroadcast();
    }
}
