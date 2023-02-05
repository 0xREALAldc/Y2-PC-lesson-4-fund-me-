//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice() internal view returns(uint256) {
        //since here we'll be interacting with a external contract we need two things
        // 1 - ABI - 
        // 2 - Address  0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
        //we get only the value for the return of `price` leaving the others blank only informing `,` to represent them
        (,int256 price,,,) = priceFeed.latestRoundData();
        // ETH in terms if USD
        // 1700.00000000

        //since `price` comes with only 8 decimals, we have to match the number of decimals that `msg.value` has that is 18 decimals
        // we'll take `price` and elevate to 10 to add 10 decimals to it below then
        // also, we will use a `typecast` with `uint256(price)` to leave the result having the same type as `msg.value`
        return uint256(price * 1e10); //1**10 == 10000000000
    }

    function getVersion() internal view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
        return priceFeed.version();
    }

    function getConversionRate(uint256 ethAmount) internal view returns (uint256) {
        uint256 ethPrice = getPrice();
        //eg: 
        // ethPrice = 1700_000000000000000000 (18 decimals)
        // ETH Sent =    1_000000000000000000 (18 decimals) (1 ETH)
        // multiply = 1700_000000000000000000_000000000000000000
        // divided  = 1700_000000000000000000
        //we'll divide the result from multiplication by 1e18 because if we don't do this, the result will have 36 decimals
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18; 
        return ethAmountInUsd;
    }
}
