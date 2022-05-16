// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract WETH is ERC20, ERC20Burnable {
    event Wrapped(address indexed account, uint256 amount);
    event Unwrapped(address indexed account, uint256 amount);

    constructor() ERC20("Wrapped Ether", "WETH", 18) {}

    fallback() external payable {
        wrap();
    }

    function wrap() public payable {
        require(msg.value > 0, "Wrap at least 1 wei");
        _mint(msg.sender, msg.value);
        emit Wrapped(msg.sender, msg.value);
    }

    function unwrap(uint256 _amount) public {
        require(_amount > 0, "Unwrap at least 1 wei");
        _burn(_amount);
        payable(msg.sender).transfer(_amount);
        emit Unwrapped(msg.sender, _amount);
    }
}
