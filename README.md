## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

## Notes To Self

### 241220

I left off at the point of putting my contract dependency variables (i.e. the AggregatorV3Interface contract address) into my deployment script and then integrating my deployment script into my test suite. Because I'm retarded, I battled this for a minute thanks to a case sensitivity issue on my import statment. This is the kind of thing that would be solved for if I had path autocompletion turned on, so it's probably worth fixing that in the relatively near term.

### 241224

It is good to have some tests before refactoring so that you know you aren't breaking anything in the process. This isn't just in terms of the business logic of your contract, but infact about the entire development and deployment process including your scripting suite.

It is important to remember the difference between `=` and `==`. Namely what I am running into is forgetting that `=` is just for setting a variable, while `==` is used for checking equivalence.

Typically, if you are calling a single value from a struct, you'll need to wrap your variable in parens and have blank values, `(address someAddress, , ,)`, but if your struct has only one value, solidity will simplify it down to a single value, `address someAddress;`

'Magic Numbers' are the idea that there might be variables used as args/parameters in some function, particularly deployment scripts and tests, that will be hard to understand when returning to a contract after some time. It is better to establish these as named constants, i.e. `uint256 public const SOME_VALUE = 1234;` at the top of your contract and then use `SOME_VALUE` as your inputs so that these are more legible. This is something that will be called out by auditors, and although it is more of an art than a science about when to use them, it is a good habit to get in to. I am noticing a pattern here in the deployment and testing landscape of where/how to use environment variables, constants, contract addresses, etc.

One thing I am struggling with in testing is the difference between `address(this)` and `msg.sender`. There is some weird difference between where the calls come from that impacts whether a function will work, i.e. for something like access controls. - `msg.sender` is supposedly the caller of the function. I'm not sure if this is _always_ an EOA, or if `msg.sender` can be a contract. with foundry, I can use the `vm.prank(SOME_Value)` to manually set the value of `msg.sender` which seems like it would be useful for testing different address values. - `address(this)` will be a contract that is making the call. Similarly I'm not sure when to best use `address(this)` in tests or deployment scripts. It seems like the main use case is contract-to-contract calls where I need a value that will not be impacted by foundry 'cheatcodes'. `vm.prank();` only sets `msg.sender` to the value for the next call; if you want to use that value for multiple calls, use prank start and prank stop (see foundry docs for more details)

`vm.expectRevert();` can be used to test a function that is intended to fail on some particular value. This is helpful for confirming specific failure cases and probably a pretty good tool to use since it is pretty straightforward to lay out a bunch of functions that just shouldn't happen. i.e. if `msg.sender` is some value, function `someFunction();` shouldn't be callable.

A best practice with storage variables is to prepend them with `s_`, so something like a list of funder addresses `address[] public funderAddress;` would be better labeled as `s_funderAddress`. This pattern is also used for immutable variables, using `i_`. `i_` is NOT for 'interface', though.

`private` variables are more gas efficient than `public` ones. Because of this, a best practice is to default variables to `private` unless explicitly desired to be callable from other contracts. Remember, `private` doesn't mean nobody can see these values at all, just that they are not accessible to other contracts _within_ the EVM. External to the EVM context, i.e. via RPC calls, anybody can see these values. What is interesting here, is that I can then manually add 'getter' functions which can call and publicly return the values in these private variables. I think this is basically reimplementing what the `public` keyword does (automatically create getter functions for a variable) but I'm not sure the more nuanced details.

`vm.deal(address, uint256)` is a cheatcode for me to set the ether balance of a given address. This is useful for setting up different users to have sufficient value in their accounts. It is as of yet unclear to me if I can use this for something like ERC20 balances. I suspect not, but perhaps there is some other cheatcode to do that step.

One thing to know about the foundry test suite is that for each test function it resets the state of the chain. So if I want to test a complex situation, that needs to be included within the singular function. Because of this, `modifier`s are really useful in the testing suite. Writing a modifier is a good way to basically set up the entire state of a contract against which you can then test small elements of how it works.

Tests should use an 'Arrange, Act, Assert' structure.

If you want to us uints as a way to generate addresses, then must be cast to a `uint160` first, because addresses are 160 bits.

There is an outstanding question about how tests work with gas costs from addresses calling the contracts. In my current tests, it doesn't seem to need to account for gas costs when asserting equality, but presumably there is some way that this ought to be accounted for. Seems like the system is automagically accounting for it? - Following up on this, I've learned some more here. When working with Anvil, the `gas_price` defaults to zero. So transactions are essentially free. Presumably when working on other chains, we might need to account for this more explicitly.

`chisel` is another CLI tool that comes with Foundry. It appeals to be a REPL of sorts into which I can write solidity code. i.e. if I type in `uint256 someValue = 1234` and hit return, I should then be able to type in `someValue` and `chisel` will return `1234`.

`forge snapshot` will print out a `.gas-snapshot` file that will include the amount of gas used for a given test / function. This is probably useful for something when doing gas optimizations, but I don't know exactly how to best use it yet.

Next up is learning all about storage and how to do gas optimization. I suspect there is some optimization to do around uint bit length (i.e. `uint8` vs `uint256`) as well as the way we do or do not map values to arrays and loop over those arrays. I am specifically interested in the risk of having an array that needs to be looped over but is too long for the gas limit of a block. This of course is a concern for gas cost optimization, but also I can imagine a for loop that attempts to iterate over such a large array that it is literally impossible for the function to work.
