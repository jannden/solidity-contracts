// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
pragma abicoder v2;

import "./WETH.sol";

contract ETHWrapper {
    WETH public WETHToken;

    event LogETHWrapped(address sender, uint256 amount);
    event LogETHUnwrapped(address sender, uint256 amount);

    constructor() {
        WETHToken = new WETH();
    }

    function wrap() public payable {
        require(msg.value > 0, "We need to wrap at least 1 wei");
        WETHToken.mint(msg.sender, msg.value);
        emit LogETHWrapped(msg.sender, msg.value);
    }

    function unwrap(uint256 value) public {
        require(value > 0, "We need to unwrap at least 1 wei");
        WETHToken.transferFrom(msg.sender, address(this), value);
        WETHToken.burn(value);
        payable(msg.sender).transfer(value);
        emit LogETHUnwrapped(msg.sender, value);
    }
}
