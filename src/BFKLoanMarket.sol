// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@solmate/auth/Owned.sol";
import "./interfaces/IPriceOracle.sol";
import "@solmate/tokens/ERC20.sol";

/**
 * STEAL THEIR BLEMFLARCK! DEATH TO EIGER!
 */
contract BFKLoanMarket is Owned(msg.sender) {
    IPriceOracle public immutable oracle;
    ERC20 public immutable blemflarck;
    ERC20 public immutable jungfrau;

    uint256 public constant COLLATERALIZATION_PERCENT = 150;
    uint256 public constant LIQUIDATION_THRESHOLD = 20;

    Round[] public priceOverrides;

    struct Loan {
        uint256 bfkAmount;
        uint256 openingPrice;
    }

    struct Round {
        int256 price;
        uint256 timestamp;
    }

    mapping(address => Loan) public loans;

    constructor(
        address bfk,
        address jfr,
        address priceOracleAddress
    ) {
        blemflarck = ERC20(bfk);
        jungfrau = ERC20(jfr);
        // 0x7d7356bF6Ee5CDeC22B216581E48eCC700D0497A EUR/USD
        oracle = IPriceOracle(priceOracleAddress);
    }

    function latestAnswer() internal view returns (uint256) {
        (, int256 answer, , uint256 timestamp, ) = oracle.latestRoundData();
        uint256 returnedAnswer = uint256(answer);
        if (
            priceOverrides[priceOverrides.length - 1].timestamp >
            timestamp - 120
        ) {
            returnedAnswer = uint256(
                priceOverrides[priceOverrides.length - 1].price
            );
        }
        return returnedAnswer;
    }

    function _loan(address loanTaker, uint256 collateral) internal {
        uint256 latestPrice = latestAnswer();
        loans[loanTaker] = Loan({
            bfkAmount: collateral,
            openingPrice: latestPrice
        });

        blemflarck.transferFrom(loanTaker, address(this), collateral);

        uint256 loanAmount = ((collateral * latestPrice) /
            10**8 /
            COLLATERALIZATION_PERCENT) * 100;
        jungfrau.transfer(loanTaker, loanAmount);
    }

    function _liquidate(
        address loanTaker,
        address liquidator,
        uint256 repayment,
        uint256 price
    ) internal {
        require(
            (price * 100) / loans[loanTaker].openingPrice <
                100 - LIQUIDATION_THRESHOLD,
            "Loan still valid"
        );
        loans[loanTaker] = Loan({bfkAmount: 0, openingPrice: 0});
        jungfrau.transferFrom(liquidator, address(this), repayment);

        uint256 liquidatorReward = (repayment / price) * 10**8;
        blemflarck.transfer(liquidator, liquidatorReward);
    }

    function loan(uint256 collateral) public {
        _loan(msg.sender, collateral);
    }

    function updatePrice(int256 price) public onlyOwner {
        priceOverrides.push(Round({price: price, timestamp: block.timestamp}));
    }
}
