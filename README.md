# Yearn Stake the Bridge 

![alt text](setup.png)

# Structure

## [L1 Deployer](https://github.com/yearn/yearn-stb/blob/master/src/L1Deployer.sol)

- Allows anyone to add a new asset to any valid Rollup
- Allows for a Rollup Admin to specify its specific EScrow Manager
- Allows for a Rollup Admin to add custom vaults for a specific asset.
- Deploys vaults and does full setup for any new assets added.

## [L2 Deployer](https://github.com/yearn/yearn-stb/blob/master/src/L2Deployer.sol)
- Receives message from L1 Deployer when a new escrow was created for a new asset.
- Deploys L2 Token, Escrow and convertor and completes setup
- Owned by L2 Admin

## [L1 Yearn Escrow](https://github.com/yearn/yearn-stb/blob/master/src/L1YearnEscrow.sol)
- Yearn specific L1 Escrow contract that handles bridge txns
- Will deposit funds into a Yearn vault over any set `minimumBuffer`
- If withdraws cannot be processed it will send shares to users when bridging back to L1.
- Rollups Admin can update the `minimumBuffer` as well as the vault it uses.


## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ make build
```

### Test

```shell
$ make tests
```

### Trace

```shell
$ make trace
```

### Gas Snapshots

```shell
$ make snapshot
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
