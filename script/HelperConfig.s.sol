// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address ethUsdPriceFeedAddress;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaConfig();
        } else {
            activeNetworkConfig = getAnvilConfig();
        }
    }

    function getSepoliaConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepolia_config =
            NetworkConfig({ethUsdPriceFeedAddress: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepolia_config;
    }

    function getAnvilConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.ethUsdPriceFeedAddress != address(0)) {
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockv3aggr = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvil_config = NetworkConfig({ethUsdPriceFeedAddress: address(mockv3aggr)});

        return anvil_config;
    }
}
