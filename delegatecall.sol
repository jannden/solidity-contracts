// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Person {
    string public name;

    constructor(string memory _name) {
        name = _name;
    }
}

contract Alice is Person {
    constructor() Person("Alice") {}

    function setName(string calldata _name) public {
        name = _name;
    }
}

contract Bob is Person {
    constructor() Person("Bob") {}

    function delegateNameChange(string calldata _name, address _delegateTo)
        external
    {
        (bool success, bytes memory returndata) = address(_delegateTo)
            .delegatecall(abi.encodeWithSignature("setName(string)", _name));
        if (success == false) {
            if (returndata.length > 0) {
                // bubble up any reason for revert
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert("Function call reverted");
            }
        }
    }
}
