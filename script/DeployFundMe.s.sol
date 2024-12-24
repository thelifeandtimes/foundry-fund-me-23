// SPDX-License-Identifier: GPLv3

pragma solidity >0.8.0 <=0.9.0;

import {Script} from "@forge-std/src/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        // anything before 'vm.startBroadcast' is not run as a transaction
        HelperConfig helperConfig = new HelperConfig();
        address EthUsdPriceFeed = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        FundMe fundMe = new FundMe(EthUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
