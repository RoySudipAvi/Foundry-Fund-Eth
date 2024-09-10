// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script} from "forge-std/Script.sol";
import {FundEth} from "../src/FundEth.sol";

contract FundEthDeploy is Script {
    FundEth public fundeth;

    function run() public returns (FundEth) {
        vm.startBroadcast();
        fundeth = new FundEth(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        vm.stopBroadcast();
        return fundeth;
    }
}
