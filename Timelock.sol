// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

// Deposit ether and wait one week to withdraw
contract Timelock {
    mapping(address => uint256) public balances;
    mapping(address => uint256) public lockTimes;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
        lockTimes[msg.sender] = block.timestamp + 1 weeks;
    }

    function withdraw() public {
        require(balances[msg.sender] > 0, "Zero balance.");
        require(block.timestamp > lockTimes[msg.sender], "Wait some more.");

        payable(msg.sender).transfer(balances[msg.sender]);
        delete balances[msg.sender];
    }
}
