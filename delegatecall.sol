// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract ContractA {
    string internal tokenName = "FunToken";

    function initialize() external {
        address contractBAddress = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
        (bool success, bytes memory returndata) = contractBAddress.delegatecall(
            abi.encodeWithSelector(
                ContractB.setTokenName.selector,
                "BoringToken"
            )
        );

        // if the function call reverted
        if (success == false) {
            // if there is a return reason string
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

contract ContractB {
    string internal tokenName = "BoringToken";

    function setTokenName(string calldata _newName) external {
        tokenName = _newName;
    }
}
