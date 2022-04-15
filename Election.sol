// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
pragma abicoder v2;

import "./Ownable.sol";

contract Election is Ownable {
    uint8 public constant CANDIDATE_A = 1;
    uint8 public constant CANDIDATE_B = 2;

    bool public electionEnded;

    mapping(uint8 => uint8) public seats;
    mapping(string => bool) public resultsSubmitted;

    struct StateResult {
        string name;
        uint256 votesCandidateA;
        uint256 votesCandidateB;
        uint8 stateSeats;
    }

    event LogStateResult(uint8 winner, uint8 stateSeats, string state);
    event LogElectionEnded(uint256 winner);

    modifier onlyActiveElection() {
        require(!electionEnded, "The election has ended already");
        _;
    }

    function submitStateResult(StateResult calldata result)
        public
        onlyActiveElection
        onlyOwner
    {
        require(result.stateSeats > 0, "States must have at least 1 seat");
        require(
            result.votesCandidateA != result.votesCandidateB,
            "There cannot be a tie"
        );
        require(
            !resultsSubmitted[result.name],
            "This state result was already submitted!"
        );

        uint8 winner;
        if (result.votesCandidateA > result.votesCandidateB) {
            winner = CANDIDATE_A;
        } else {
            winner = CANDIDATE_B;
        }

        seats[winner] += result.stateSeats;
        resultsSubmitted[result.name] = true;

        emit LogStateResult(winner, result.stateSeats, result.name);
    }

    function currentLeader() public view returns (uint8) {
        if (seats[CANDIDATE_A] > seats[CANDIDATE_B]) {
            return CANDIDATE_A;
        }
        if (seats[CANDIDATE_B] > seats[CANDIDATE_A]) {
            return CANDIDATE_B;
        }
        return 0;
    }

    function endElection() public onlyActiveElection onlyOwner {
        electionEnded = true;
        emit LogElectionEnded(currentLeader());
    }
}
