// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title TokenLock
 * Locks ERC20 tokens for a specified duration
 * Supports multiple locks per user
 */
contract TokenLock is ReentrancyGuard, Ownable {
    struct Locker {
        uint256 amount;
        bool isWithdrawn;
    }

    IERC20 public tokenInstance;
    mapping(address => mapping(uint256 => Locker))
        public lockedTokensByWithdrawalAddress;
    mapping(address => uint256[]) public unblockTimesByWithdrawalAddress;
    uint256 public lockDuration;

    event TokenLocked(address indexed user, uint256 amount, uint256 unlockTime);
    event TokenWithdrawn(
        address indexed user,
        uint256 amount,
        uint256 unlockTime
    );

    constructor(
        address _initialOwner,
        IERC20 _tokenInstance,
        uint256 _lockDuration
    ) Ownable(_initialOwner) {
        tokenInstance = _tokenInstance;
        lockDuration = _lockDuration;
    }

    function depositTokens(uint256 _amount) external nonReentrant {
        require(_amount > 0, "Deposit amount should be greater than 0");
        uint256 allowance = tokenInstance.allowance(msg.sender, address(this));
        require(allowance >= _amount, "Check the token allowance");

        // Transfer token to contract address
        require(
            tokenInstance.transferFrom(msg.sender, address(this), _amount),
            "Transfer failed"
        );

        // Define unlock time
        uint256 unlockTime = block.timestamp + lockDuration;

        // Add tokens to user's locked tokens
        lockedTokensByWithdrawalAddress[msg.sender][unlockTime]
            .amount += _amount;

        // Add unlock time to user's unlock times
        unblockTimesByWithdrawalAddress[msg.sender].push(unlockTime);

        // Emit event
        emit TokenLocked(msg.sender, _amount, unlockTime);
    }

    function withdrawTokensByUnblockTime(
        uint256 _unlockTime
    ) external nonReentrant {
        require(_unlockTime <= block.timestamp, "Tokens are locked");
        require(
            !lockedTokensByWithdrawalAddress[msg.sender][_unlockTime]
                .isWithdrawn,
            "Tokens are already withdrawn"
        );

        uint256 amount = lockedTokensByWithdrawalAddress[msg.sender][
            _unlockTime
        ].amount;
        require(amount > 0, "No tokens to withdraw");

        // Update withdrawal status
        lockedTokensByWithdrawalAddress[msg.sender][_unlockTime]
            .isWithdrawn = true;

        // Transfer tokens back to user
        require(tokenInstance.transfer(msg.sender, amount), "Transfer failed");

        // Emit event
        emit TokenWithdrawn(msg.sender, amount, _unlockTime);
    }
}
