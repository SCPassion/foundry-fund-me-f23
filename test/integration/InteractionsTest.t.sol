// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {PriceConverter} from "../../src/PriceConverter.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

// inherit everything from the Test contract

contract InteractionsTest is Test {
    FundMe fundMe;
    // address who we use for the test, with no ether in it
    address USER = makeAddr("USER"); // a function in forge-std but not in vm
    uint256 constant SEND_VALUE = 0.1 ether; // Decimal don't work in solidity if you do 0.1 ether, that make it 100000000000000000 wei
    uint256 constant STARTING_BALANCE = 20 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe depoly = new DeployFundMe();
        fundMe = depoly.run(); // The testing depends on DepolyFundMe contract now.
        vm.deal(USER, STARTING_BALANCE); // Give our fake user 10 ether to start
    }

    function testUserCanFundInteractions() public {
        // Instead of funding with directly with function
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assertEq(address(fundMe).balance, 0);
    }
}
