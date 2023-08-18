// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// 1. Deploy mocks when we are on a local anvil chain
// 2. Keep track of contract address across differnt chains
// Sepolia ETH/usd and mainnet ETH/usd are different addresses

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // If we are on a local anvil, we depoly mock contract
    // Otherwise, grab the existing address from the live network
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed; // Eth/USD price feed address
    }

    constructor() {
        // This is the iniialization function
        if (block.chainid == 11155111) {
            // 11155111 is the chainID for sepolia
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        // price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        // price feed address
        NetworkConfig memory ethConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ethConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        // There is no contract existed on the anvil chain

        if (activeNetworkConfig.priceFeed != address(0)) {
            // If we already deployed a mock contract, we don't need to deploy it again
            // If the priceFeed is not 0, then we already deployed a mock contract
            // Address is default to address 0
            // return activeNetworkConfig and don't run the rest of it
            return activeNetworkConfig;
        }
        //1. Deploy the mocks, ie. a fake dummy contract
        //2. Return the mock address

        vm.startBroadcast(); // deploy to anvil chain if rpc not specified
        // Deploy own pricefeed, we need our own pricefeed contract!
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        ); // 18 is the decimal, 2000 is the initial price
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}
