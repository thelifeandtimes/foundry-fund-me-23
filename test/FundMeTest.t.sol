// SPDX-License-Identifier: GPLv3

pragma solidity >0.8.0 <=0.9.0;

import {Test, console} from "@forge-std/src/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        // by putting DeployFundMe() into the setup, we are also testing my scripts, which seems like a wise decision overall. Basically turns this test suite from pure unit tests into an integration testing suite.
    }

    function testMinimumDollarAmount() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSenger() public view {
        assertEq(fundMe.i_owner(), address(this));
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }
}
