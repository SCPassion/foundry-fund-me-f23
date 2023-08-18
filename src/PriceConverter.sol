//Create a library

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// 1. Limit self-triage to 15/20 minutes (limit your hard time to 15 - 20 minute)
// 2. Don't be afraid to ask AI, but don't skip learning (learn will let you know when AI is wrong) "Hallucinations"
// 3. Use the forums!
// 4. If AI doesn't know, the forums don't have an answer. Google the exact error
// 5. Post in stack exchange or peeranha
// 6. Posting an issue on github/git (interacting with community)

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol"; // import from github

// library canot have any state variables, all functions have to be marked internal
library PriceConverter {
    // Return the value of ethereum in terms of usds
    function getPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        // Not modifying the state! so view is fine
        //Address 0x694AA1769357215DE4FAC081bf1f309aDC325306
        // ABI
        (, int256 price, , , ) = priceFeed.latestRoundData();
        // Price of ETH in terms of USD
        // eg. 200000000000 Price has 8 dicimal place, msg.value has 18 decimal place. To match price with msg.value, it has to * 10**10
        return uint256(price * 1e10); // There aren't any decimal place in solidity! only works with whole number
    }

    // convert msg.value to usd with get price function
    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        // 1 ETH?
        // 2000_000000000000000000
        uint256 ethPrice = getPrice(priceFeed); // Get the current price of eth

        // (2000_000000000000000000 * 1_000000000000000000) / 1e18;
        // $2000 = 1 ETH ( 2000 with 18 decimal places)
        // Always multiply before divide! 1e18 * 1e18 = 1e36 -> to get it back to 1e18!
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18; // ethAmount and ethPrice have 18 digits
        return ethAmountInUsd;
    }

    function getVersion() internal view returns (uint256) {
        return
            AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306)
                .version();
    }
}
