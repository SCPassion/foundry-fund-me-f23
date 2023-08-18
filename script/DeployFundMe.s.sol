// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig(); // This will not be deployed to the blockchain. Hence no gas fee
        // Return a struct, but this struct is only one variable, it return just the address
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig(); // Get the price feed address for different network
        // Pass the price feed address to the constructor of FundMe

        // try to avoid all warnings
        vm.startBroadcast();
        // Mock contract
        FundMe fundMe = new FundMe(ethUsdPriceFeed); // Refactoring your code
        vm.stopBroadcast();
        return fundMe;
    }
}
