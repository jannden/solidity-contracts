// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Bakery {
    // index of created contracts
    address[] public contracts;

    // useful to know the row count in contracts index
    function getContractCount() public view returns (uint256 contractCount) {
        return contracts.length;
    }

    // deploy a new contract
    function newCookie() public returns (address newContract) {
        Cookie c = new Cookie();
        contracts.push(address(c));
        return address(c);
    }
}

contract Cookie {
    // suppose the deployed contract has a purpose
    function getFlavor() public pure returns (string memory flavor) {
        return "mmm ... chocolate chip";
    }
}
