// Get funds from users into the contract
// Withdraw funds to the ower of the contract
// Set a minimum funding value in USD

// SPDX-License-Identifier: MIT

// Style Guide
// If you varialbe persist across multiple function calls, you need to store them in storage -> s_
// immutable -> i_
// contstant -> CAPITAL

pragma solidity 0.8.18;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol"; // import from github

// constant and immutable: Gas optimizations, they can only be declared and updated once.
// Updating out require statemtn for gas efficiency, every single one of the error log needs to store individually

error FundME__NotOwner(); // custom error for replacing the errorstring for gas efficiency

// When you name the error with your contract name, it will be easier to find the error in the error log

contract FundMe {
    //attach the functioss in the PriceConverter library to all uint256
    using PriceConverter for uint256;

    mapping(address funder => uint256 amountFunded)
        private s_addressToAmountFunded; // Just easier to read to add name in mapping
    address[] private s_funders; // private variable are more gas efficient

    // Variable that we set one time but outside of the same line that they're declared (eg. in the constructor)
    // Mark as immutable
    address private immutable i_owner; // add i_ to set convention , similar gas saving as constant keyword
    uint256 public constant MINIMUM_USD = 5 * 1e18; // minimumUsd is assigned once outside of a function at compile time and never change it. -> Constant
    AggregatorV3Interface private s_priceFeed; // private variable, only accessible inside the contract

    // constructor is a keyword in solidity, only run when you initially deploy a contract.
    // When somebody call fund or withdraw, this is not deploying a contract. No change to the owner.
    // Pass a constructor parameter an address that we want to use
    constructor(address priceFeed) {
        // Function that is immedicately called whenever you deplot your contract in the exact same transaction (same in deploying contract and calling this)
        i_owner = msg.sender; // depolyer of the contract
        s_priceFeed = AggregatorV3Interface(priceFeed); // Assign the priceFeed to the s_priceFeed
        // This AggregatorV3Interfact is a contract that we import from chainlink, not MockContract!
    }

    //uint256 public myValue = 1;
    // Allow users to send money
    // Have a minimum $ sent $5

    // 1. How do we send ETH to thi s contract
    // Value field!!! The amount of native blockchain cryptocurrency that get sent with every transaction
    // To allow a function in solidity to accept this value ie. native blockchain currency, add payable to the function
    //Payable keyword will make the Remix function turns red

    function fund() public payable {
        // anyone should be able to call this function, so public
        // msg.value.getConversionRate() : first input variable for a library function here uint256 ethAmount is the type you are using with the library
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "Didn't send enough ETH"
        ); // ie18 = 1 ETH = 100000000000000000 WEI = 1 * 10 ** 18 // Require keyword is a checker
        s_funders.push(msg.sender); // save the sender of the transaction
        s_addressToAmountFunded[msg.sender] += msg.value;
        // The msg.value should be > than xxx, otherwise revert the transaction. With a revert msg
    }

    // What is a revert?
    // Undo any actions that have been done previously, and send back the gas supposed to be used for the remaining transaction after the require function
    // Gas will be charge for myValue = myValue + 2; as it is executed. After the require line, the gas which is supposed to use afterward,
    // Will be refunded.

    function cheaperWithdraw() public onlyOwner {
        uint256 fundedersLength = s_funders.length; // Save the s_funders.length to memory, instead of calling in stoage in the for loop
        for (
            uint256 funderIndex = 0;
            funderIndex < fundedersLength;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        // reset the array
        s_funders = new address[](0); // create a new address array with a length of 0

        // withdraw funds, in solidity, in order to send native blockchain currency, only payable address can work.
        // address(this).balance is the balance of this contract
        //Call, which can call any function in all ethereum without even having the ABI
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }(""); //"" is the function we want to call, here no function
        require(callSuccess, "Call failed");
    }

    function withdraw() public onlyOwner {
        // for loop.
        // for(/*starting index, ending index, step amount*/)
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        // reset the array
        s_funders = new address[](0); // create a new address array with a length of 0

        // withdraw funds, in solidity, in order to send native blockchain currency, only payable address can work.
        // address(this).balance is the balance of this contract
        //Call, which can call any function in all ethereum without even having the ABI
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }(""); //"" is the function we want to call, here no function
        require(callSuccess, "Call failed");
    }

    // Only the owner of the contract to be able to withdraw the funds: When contract deploy, we assign some addresses to be the owner
    // create a modifier: allow us to create a keyword that we can put right in the function declaration to add functionalities
    modifier onlyOwner() {
        //require(msg.sender == i_owner, "Sender is not owner!"); // Check owner;
        if (msg.sender != i_owner) {
            revert FundME__NotOwner();
        } // No need to store and emit the long string error
        //revert keyword does the exact same thing as require does without the conditions.

        _; // The order when whatever else you want to do inside the attached function
        //... After the function attached called, go back here to check whatever to do here.
    }

    // When withdraw function is called, it will execute what's in this modifier first

    // Order inside the onlyOwner is important
    // modifier onlyOwner() {
    //     _; // Then do whateve inside the attached function
    //     require(msg.sender == owner, "Sender is not owner!"); // Then Check owner;
    // }

    // Send the contract with money without calling the fund function?
    // If you will do that, fund() will not trigger and we wouldn't know which address send us money
    // By routing back to fund(), they will automatically get credits and we know who is sending us the money.

    // What happens if someone sends this contract ETH without calling the fund function?
    receive() external payable {
        // If someone send money accidently without calling fund() function.
        //It will still route them to the fund() function.
        fund();
    }

    fallback() external payable {
        fund();
    }

    /** Getter Functions */
    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}

// Things to learn later
// 1. Enums
// 2. Events
// 3. Try / Catch
// 4. Function Selectors
// 5. abi.encode / decode
// 6. Hashing
// 7. Yul / Assumbly
