# Cheatsheet for testing

## Install chainlink dependencies, ie let foundry know where to pull the chainlink code from
Find the path from github, set version and no commit.
```
forge install smartcontractkit/chainlink-brownie-contracts@0.6.1 --no-commit
// This will give us the path for where it is installing in.
///home/bernard/foundry-f23/foundry-fund-me-f23/lib/chainlink-brownie-contracts
```

## In foundry.toml
```
remappings = ["@chainlink/contracts/=lib/chainlink-brownie-contracts/contracts/"]
```
## Compile the project using
```
forge compile / forge build
```

## Test the test files
```
forge test
forge test -vv // test with logs visible, v = number of logs
forge test --match-test testPriceFeedVersionIsAccurate // test specific function

//They are using anvil blockchain to test
```

## Forked testing
Problem is you need to make a lot of api calls, can be costly. But, the problem is there are many tests you cannot be done without forking, when you test with external functions.
```
source .env // load our environment variables
$echo $SEPOLIA_RPC_URL
forge test --match-test testPriceFeedVersionIsAccurate -vvvvv --fork-url $SEPOLIA_RPC_URL 
or
forge test -vvvvv --fork-url $SEPOLIA_RPC_URL  // run all tests on a forked sepolia
forge test -vvvvv --fork-url $MAINNET_RPC_URL  // run all tests on a forked mainnet

// grab our api key from alchemy
// Anvil will spin up but it will take a copy of the sepolia rpc url. It spin up an anvil but it simulate our transaction as if they're on the sepolia chain. Not an empty chain anymore.
// Return a hex value of 4
```
# Important to have no error in forked ethereum mainnet deployment
## Coverage
See how many lines of our code are actually tested
```
forge coverage --rpc-url $SEPOLIA_RPC_URL 
or
forge coverage --fork-url $SEPOLIA_RPC_URL

// Sample output
| File                      | % Lines       | % Statements  | % Branches    | % Funcs      |
|---------------------------|---------------|---------------|---------------|--------------|
| script/DeployFundMe.s.sol | 0.00% (0/3)   | 0.00% (0/3)   | 100.00% (0/0) | 0.00% (0/1)  |
| src/FundMe.sol            | 14.29% (2/14) | 13.33% (2/15) | 0.00% (0/4)   | 25.00% (1/4) |
| src/PriceConverter.sol    | 0.00% (0/8)   | 0.00% (0/13)  | 100.00% (0/0) | 0.00% (0/3)  |
| Total                     | 8.00% (2/25)  | 6.45% (2/31)  | 0.00% (0/4)   | 12.50% (1/8) |

* Get the percentage as high as possible (100% might not be possible but 14% is not good)
```

## Deploy Script

```
forge script script/DeployFundMe.s.sol
```
## How to make it work on other chain??
Make it modular with address or external systems

## How to not always making calls to alchemy node reduce the bill? do locally as long as possible

## chisel
Allow us to write solidity in terminal and execute it. Quickly check some small solidity pieces of code.
```
chisel

// Press control + C 2 times to exit
```

## Check gas cost for the test function
```
forge snapshot --match-test testWithDrawFromMultipleFunders
or
forge snapshot
```

## When working with anvil, the gas price is default to 0. So, no matter how much gas you spent, it will go to  0. It doesn't matter it is forked or not
Example code to include gas
```
        uint256 gasStart = gasleft(); // How much gas left in your transaction call, a built-in function in solidity.
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner()); // The next transaction is going to be sent by the owner. Only owner can call withdraw
        // 200 gas
        fundMe.withdraw(); // This is the function that we would like to test

        uint256 gasEnd = gasleft(); // should have 800 here.
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);
```

## To reduce the gas used, we need to understand storage
To check FundMe contract's storage in different ways
```
forge inspect FundMe storageLayout
```

## Style Guide from Chainlink
https://github.com/smartcontractkit/chainlink/blob/develop/contracts/STYLE.md

## Install the foundry-devops from
```
forge install Cyfrin/foundry-devops --no-commit
```

## Fund our FundMe contract with program
```
``` 