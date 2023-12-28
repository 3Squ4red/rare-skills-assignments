> The OZ upgrade tool for hardhat defends against 6 kinds of mistakes. What are they and why do they matter?

Following are the mistakes the OZ upgrade tool for hardhat checks for:

1. **External Library Linking**:  Linking upgradeable contracts to external libraries is not allowed because it’s not known at compile time what implementation is going to be linked, thus making it very difficult to guarantee the safety of the upgrade operation.
2. **State Variable Assignment**: It is not allowed to initialize state variables in the upgradeable contracts like `uint256 public hasInitialValue = 42;` because any future versions of the contract will not have these fields set.
3. **Immutable State Variable**: Immutables are not allowed in upgradeable contracts because (i.) Upgradeable contracts do not have constructors but initializers, therefore they can’t handle immutable variables. (ii.) Since the immutable variable value is stored in the bytecode its value would be shared among all proxies pointing to a given contract instead of each proxy’s storage.
4. **Constructors**: Constructors are not allowed in upgradeable contracts because the code within a logic contract’s constructor will never be executed in the context of the proxy’s state. Consequently, if there were any variable initializations or setup done in the constructor of the logic contract, it would get stored in the logic contract's storage and NOT in the proxy's storage.
5. `delegatecall`/`selfdestruct`: These opcodes are not allowed to be used in the logic contract because if a direct call to the logic contract triggers a `selfdestruct` operation, then the logic contract will be destroyed, and the proxy will end up delegating all calls to an address without any code. A similar effect can be achieved if the logic contract contains a `delegatecall` operation. If the contract can be made to `delegatecall` into a malicious contract that contains a `selfdestruct`, then the calling contract will be destroyed.
6. Missing public `upgradeTo`: If a logic contract that follows the UUPS pattern, upgrades to a newer version of the contract that doesn't have a public `upgradeTo` function, then it would disable the upgrading mechanism. Therefore, to prevent this, the plugin checks for the presence of a public `upgradeTo` in the newer version.
7. Incompatible storage layout: The storage layout of the newer contract version must be compatible with the older one. Either changing the type/name, the order of declaration, introducing a new variable before the older ones, or removing an existing variable can cause the upgraded version of the contract to have its storage values mixed up, and can lead to critical errors in the application.

> What is a beacon proxy used for?

If there are multiple proxies all of which are using the same logic contract, then the caller (or the proxy admin) would have to call the `upgradeTo` function on each of the proxies separately, one-by-one in order to upgrade the contract. Initiating different transactions would be quite expensive for the caller in this case.

Beacon proxies streamlines this process and saves the gas cost of initiating separate transactions for the caller by using a separate contract (in OZ it's called `UpgradeableBeacon`) to hold the address of the logic contract. When the caller wants to upgrade the contract, they would just have to call the `upgradeTo` function on the `UpgradeableBeacon` contract, and the proxies using this beacon would automatically get updated.

> Why does the openzeppelin upgradeable tool insert something like `uint256[50] private __gap;` inside the contracts? To see it, create an upgradeable smart contract that has a parent contract and look in the parent.

When a contract extends another contract, the state variables of the parent contract are assigned the storage slots first, and the state variables of the child contract are assigned the slots starting from right next the last slot used in the parent contract.
```solidity
contract A {
    uint256 a = 1; // slot 0
    uint256 b = 2; // slot 1
}

contract B is A {
    uint256 c = 3; // slot 2
    uint256 d = 4; // slot 3
}
```
If the parent contract i.e. `A`  is updated to include some new state variables after `b`, then it's slot would collide with the slot used by `c` in the older version. To prevent this from happening, OZ inserts `uint256[50] private __gap;` in the parent contract, as this reserves 51 slots which can be used by the new state variables of the future versions.

> What is the difference between initializing the proxy and initializing the implementation? Do you need to do both? When do they need to be done?

Initializing the proxy means setting the logic contract address and the admin address (not in UUPS), and this is done through the constructor of the proxy. Initializing the implementation means calling the `initialize` function (if there is any) on the logic contract DIRECTLY (not through the proxy) so that no one else in future can call it again (because of `initializer` modifier) directly as that could lead to granting the caller certain privileges they should not have.

Initializing the proxy is necessary at all times as the upgradeability would simply not work without it. However, the implementation needs to initialized only if the `_disableInitializers()` is not called in it's constructor.

> What is the use for the [reinitializer](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/master/contracts/proxy/utils/Initializable.sol#L119)? Provide a minimal example of proper use in Solidity

A `reinitializer` may be used after the original initialization step. This is essential to configure modules that are added through upgrades and that require initialization. The initialization modifiers (`initializer` and `reinitializer`) use a version number. Once a version number is used, it is consumed and cannot be reused.

For example:
```solidity
contract MyToken is ERC20Upgradeable {
    function initialize() initializer public {
        __ERC20_init("MyToken", "MTK");
    }
}

contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
    function initializeV2() reinitializer(2) public {
        __ERC20Permit_init("MyToken");
    }
}
```

When version is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer` cannot be nested. If one is invoked in the context of another, execution will revert.
