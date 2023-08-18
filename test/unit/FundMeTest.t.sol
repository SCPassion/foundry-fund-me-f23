// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {PriceConverter} from "../../src/PriceConverter.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

// inherit everything from the Test contract

contract FundMeTest is Test {
    FundMe fundMe;
    // address who we use for the test, with no ether in it
    address USER = makeAddr("USER"); // a function in forge-std but not in vm
    uint256 constant SEND_VALUE = 0.1 ether; // Decimal don't work in solidity if you do 0.1 ether, that make it 100000000000000000 wei
    uint256 constant STARTING_BALANCE = 20 ether;
    uint256 constant GAS_PRICE = 1;

    // Setup always run before the test
    function setUp() external {
        // The owner of FundMe is actually the fundmeTest but not the message.sender (not us)
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306); //the input parameter is depend on the constructor in the FundMe contract
        DeployFundMe depolyFundMe = new DeployFundMe();
        fundMe = depolyFundMe.run(); // The testing depends on DepolyFundMe contract now.
        vm.deal(USER, STARTING_BALANCE); // Give our fake user 10 ether to start
    }

    // Order of execution: setUp -> test -> Reset -> setUp -> test -> Reset -> setUp -> test -> Reset

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18); // Be sure that Mimimum USD in FundMe is 5e18
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.getOwner(), msg.sender); // Be sure that owner is the address of fundMeTest
    }

    // The contract for eth 0x694AA1769357215DE4FAC081bf1f309aDC325306 is not existed
    // This eth contract is required for constructor of FundMe contract, as a result, the test will fail if there is no rpc specification
    // When run test in foundry, with no rpc specification, it spins up a local blockchain anvil, and delete it after the test
    // When run forge test with no rpc, it spin up a new anvil chain, and the call to a contract that does not exist!
    function testPriceFeedVersionIsAccurate() public {
        // This is a unit test
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithEnoughEth() public {
        // Test the revert fail function
        // assert(This tx failsa/reverts)
        vm.expectRevert(); // next line should revert
        fundMe.fund(); // send 0 value
    }

    // address: knowing how is doing what canbe confusing. Want to be very explicit about who is sending the transactions
    // Use Prank to always know exactly who's sending what call! This only works in test and in foundry

    function testFundUpdatesFundedDataStructure() public {
        // Prank sets to msg.sender to specified address for the next call.
        vm.prank(USER); // The next TX will be sent by USER
        fundMe.fund{value: SEND_VALUE}(); // send 10 eth

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    //Any test we write after this modifier, we can add this funded to our function
    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert(); // The next transaction is going to revert, vm.prank is not a transaction to revert
        vm.prank(USER); // USER is not the owner obviously, it is an address that we use for testing
        fundMe.withdraw();
    }

    // Test withdraw with the actual owner
    function testWithDrawWithASingleFunder() public funded {
        // Arrange, ie. setup the test
        uint256 startingOwnerBalance = fundMe.getOwner().balance; // Owner balance
        uint256 startingFundMeBalance = address(fundMe).balance; // Balance of the fundMe contract

        // Act, ie. do the action you wanted to test
        vm.prank(fundMe.getOwner()); // The next transaction is going to be sent by the owner. Only owner can call withdraw
        fundMe.withdraw(); // This is the function that we would like to test

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0); // The balance of the fundMe contract should be 0 after withdraw
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        ); // The owner balance should be the sum of the owner balance and the fundMe balance
    }

    function testWithDrawFromMultipleFunders() public funded {
        //Arrange

        // If you wanna to use number to generate address, use uint160 since this has the same bytes as address
        uint160 numberOfFunder = 10;
        uint160 startingFunderIndex = 1; // When writing your test, don't send stuff to address(0) it sometimes revert!
        for (uint160 i = startingFunderIndex; i < numberOfFunder; i++) {
            // vm.prank new address
            // vm.deal new address
            // Combine prank and deal, we use hoax in forge.std library
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
            // fund the fundMe contract
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance; // Owner balance
        uint256 startingFundMeBalance = address(fundMe).balance; // Balance of the fundMe contract

        // Act
        vm.startPrank(fundMe.getOwner()); // The next transaction is going to be sent by the owner. Only owner can call withdraw
        fundMe.withdraw(); // Anything between startPrank and stopPrank will be sent by the fundMe.getOwner())
        vm.stopPrank();

        // Assert
        assertEq(address(fundMe).balance, 0); // The balance of the fundMe contract should be 0 after withdraw
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            fundMe.getOwner().balance
        ); // The owner balance should be the sum of the owner balance and the fundMe balance
    }

    // What can we do to work with addresses outside of our system?
    // 1. Unit
    //    - Testing a specific part of our code
    // 2. Integration
    //    - Testing how our codes work with other parts of our code
    // 3. Forked
    //    - Testing our code on a simulated real environment
    // 4. Staging
    //    - Testing our code in a real enviornment that is not production,
    //      ie. deploy our code in testnet or even mainnet and run everything in real environemtn to make sure things work correctly.

    // Chisel

    function testWithDrawFromMultipleFundersCheaper() public funded {
        //Arrange

        // If you wanna to use number to generate address, use uint160 since this has the same bytes as address
        uint160 numberOfFunder = 10;
        uint160 startingFunderIndex = 1; // When writing your test, don't send stuff to address(0) it sometimes revert!
        for (uint160 i = startingFunderIndex; i < numberOfFunder; i++) {
            // vm.prank new address
            // vm.deal new address
            // Combine prank and deal, we use hoax in forge.std library
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
            // fund the fundMe contract
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance; // Owner balance
        uint256 startingFundMeBalance = address(fundMe).balance; // Balance of the fundMe contract

        // Act
        vm.startPrank(fundMe.getOwner()); // The next transaction is going to be sent by the owner. Only owner can call withdraw
        fundMe.cheaperWithdraw(); // Anything between startPrank and stopPrank will be sent by the fundMe.getOwner())
        vm.stopPrank();

        // Assert
        assertEq(address(fundMe).balance, 0); // The balance of the fundMe contract should be 0 after withdraw
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            fundMe.getOwner().balance
        ); // The owner balance should be the sum of the owner balance and the fundMe balance
    }
}
