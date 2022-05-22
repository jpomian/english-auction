// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8;

contract Auction{

    address payable public beneficiary;
    uint256 public auctionEndTime;
    uint256 public bidBond;
    uint256 public startingBid;
    
    address public highestBidder;
    uint256 public highestBid; 
    bool hasEnded;
    
    mapping(address => uint256) depositCashback;
    mapping(address => bool) isEligible;
    
    event highestBidIncreased(address bidder, uint256 amount);
    event auctionEnded(address winner, uint256 amount);
    
    constructor(address payable _beneficiary, uint256 _biddingTime, uint256 _bidBond, uint256 _startingBid) {
        beneficiary = _beneficiary;
        auctionEndTime = block.timestamp + (_biddingTime * 60 seconds);
        bidBond = _bidBond;
        startingBid = _startingBid;
    }

    function deposit() public payable {
        
        require(auctionEndTime > block.timestamp, "Auction has ended."); 
        
        require(msg.sender != beneficiary, "Seller cannot be a buyer.");

        require(!isEligible[msg.sender], "User already made a deposit."); 

        require(msg.value >= bidBond, "Insufficient amount of ether was sent for deposit."); 


        isEligible[msg.sender] = true;
        depositCashback[msg.sender] += msg.value;
        
    }

    function bid() public payable {

        uint256 highestIncrementedBid = highestBid * 110 / 100;

        require(auctionEndTime > block.timestamp, "Auction has ended.");

        require(msg.sender != beneficiary, "Seller cannot be a buyer."); 

        require(msg.sender != highestBidder, "Your bid is already top bid."); 

        require(isEligible[msg.sender], "To take part in auction, one must deposit required amount of ether."); 

        require(msg.value >= startingBid, "Your bid is smaller than the starting bid."); 

        if(msg.value >= highestIncrementedBid) {
            depositCashback[msg.sender] += msg.value;
            highestBidder = msg.sender;
            highestBid = msg.value;
            emit highestBidIncreased(msg.sender, msg.value);
        }
        else {
            revert("Bid should be at least 10% higher than current highest bid.");
        }
     }
     function withdraw() public payable returns(bool) {

        //require(hasEnded,"You Cannot Withdraw Until The Auction Has Ended");

        uint256 amount = depositCashback[msg.sender];

        if(amount > 0) {
            depositCashback[msg.sender] = 0;
        }
        
        if(!payable(msg.sender).send(amount)) {
            depositCashback[msg.sender] = amount;
        }

        return true;
    }

    function auctionEnd() public {

        require(block.timestamp > auctionEndTime, "The Auction Cannot End Before The Specified Time");

        if(hasEnded)
            revert("Auction is already over.");
        
        hasEnded = true;

        emit auctionEnded(highestBidder, highestBid);
        beneficiary.transfer(highestBid);
    }
}
