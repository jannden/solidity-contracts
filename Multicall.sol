// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/*************************
// TEST WITH THIS SCRIPT
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MultiCall", function () {
  let testContract1;
  let testContract2;

  before(async () => {
    const TestMultiCall1 = await ethers.getContractFactory("TestMultiCall");
    testContract1 = await TestMultiCall1.deploy();
    await testContract1.deployed();

    const TestMultiCall2 = await ethers.getContractFactory("TestMultiCall");
    testContract2 = await TestMultiCall2.deploy();
    await testContract2.deployed();
  });

  it("should batch call to several contracts", async function () {
    const MultiCall = await ethers.getContractFactory("MultiCall");
    const multiCallContract = await MultiCall.deploy();
    await multiCallContract.deployed();

    const functionBytes1 = testContract1.encodeFunction(2);
    const functionBytes2 = testContract2.encodeFunction(3);

    const result = await multiCallContract.multiCall( [testContract1.address, testContract2.address], [functionBytes1, functionBytes2]);
    expect(result).to.eql([ethers.utils.hexlify(ethers.utils.zeroPad(2*2, 32)),ethers.utils.hexlify(ethers.utils.zeroPad(3*2, 32))]);
  });
});
*************************/

contract MultiCall {
    function multiCall(address[] calldata targets, bytes[] calldata data)
        external
        view
        returns (bytes[] memory)
    {
        require(targets.length == data.length, "target length != data length");

        bytes[] memory results = new bytes[](data.length);

        for (uint256 i; i < targets.length; i++) {
            (bool success, bytes memory result) = targets[i].staticcall(
                data[i]
            );
            require(success, "call failed");
            results[i] = result;
        }

        return results;
    }
}

contract TestMultiCall {
    function multiplyNumber(uint256 _number) external pure returns (uint256) {
        return _number * 2;
    }

    function encodeFunction(uint256 _number)
        external
        pure
        returns (bytes memory)
    {
        // The two return statements are equal, they return the same thing
        return abi.encodeWithSignature("multiplyNumber(uint256)", _number);
        // return abi.encodeWithSelector(this.multiplyNumber.selector, _number);
    }
}
