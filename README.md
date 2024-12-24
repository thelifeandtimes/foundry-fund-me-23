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

One thing I am struggling with in testing is the difference between `address(this)` and `msg.sender`. There is some weird difference between where the calls come from that impacts whether a function will work, i.e. for something like access controls. - `msg.sender` is supposedly the caller of the function. I'm not sure if this is _always_ an EOA, or if `msg.sender` can be a contract. with foundry, I can use the `vm.prank(SOME_Value)` to manually set the value of `msg.sender` which seems like it would be useful for testing different address values. - `address(this)` will be a contract that is making the call. Similarly I'm not sure when to best use `address(this)` in tests or deployment scripts. It seems like the main use case is contract-to-contract calls where I need a value that will not be impacted by foundry 'cheatcodes'.

`vm.expectRevert();` can be used to test a function that is intended to fail on some particular value. This is helpful for confirming specific failure cases and probably a pretty good tool to use since it is pretty straightforward to lay out a bunch of functions that just shouldn't happen. i.e. if `msg.sender` is some value, function `someFunction();` shouldn't be callable.

A best practice with storage variables is to prepend them with `s_`, so something like a list of funder addresses `address[] public funderAddress;` would be better labeled as `s_funderAddress`. This pattern is also used for immutable variables, using `i_`. `i_` is NOT for 'interface', though.

`private` variables are more gas efficient than `public` ones. Because of this, a best practice is to default variables to `private` unless explicitly desired to be callable from other contracts. Remember, `private` doesn't mean nobody can see these values at all, just that they are not accessible to other contracts _within_ the EVM. External to the EVM context, i.e. via RPC calls, anybody can see these values.
