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
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4 | 6);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert(); // the next line should be expected to revert, else the test should fail
        fundMe.fund(); // value sent is 0, as the default value if nothing is sent
    }

    function testFundSucceedsWithEnoughEth() public {
        fundMe.fund{value: 1e18}();
    }
}
