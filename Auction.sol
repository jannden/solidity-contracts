// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract Auction {
    address manager;
    address[] pastWinners;
    address[] bidders;
    mapping(address => uint256) bidAmountsToBidders;
    uint256 public minPriceToEnter;

    constructor() {
        manager = msg.sender;
        minPriceToEnter = 0.01 ether;
    }

    function enter() public payable {
        require(
            msg.value >= minPriceToEnter,
            "You haven't contributed enough Ether."
        );
        bidders.push(msg.sender);
        bidAmountsToBidders[msg.sender] = msg.value;
    }

    function pickWinner() public managersOnly {
        require(bidders.length > 0, "No bidders entered.");
        uint256 highestBid;
        address currentWinner;

        // Select the highest bidder
        for(uint i = 0; i < bidders.length; i++) {
            if(bidAmountsToBidders[bidders[i]] > highestBid) {
                currentWinner = bidders[i];
                highestBid = bidAmountsToBidders[currentWinner];
            }
        }

        // Return funds to losing bidders and reset current bids
        for(uint i = 0; i < bidders.length; i++) {
            if(bidders[i] != currentWinner) {
                payable(bidders[i]).transfer(bidAmountsToBidders[bidders[i]]);
            }
            bidAmountsToBidders[bidders[i]] = 0;
        }

        // Save current winner
        pastWinners.push(currentWinner);

        // Reset bidders
        delete bidders;
    }

    function getPastWinners() public view returns (address[] memory) {
        return pastWinners;
    }

    modifier managersOnly() {
        require(msg.sender == manager, "Only managers can perform this action.");
        _; // this will get replaced by the function which uses this modifier
    }
}
