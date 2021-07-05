// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract Auction {
    address payable public beneficiary;
    uint public auctionEndTime;
    uint public bidBondInEthers;
    string public hashOfAuction;

    address public highestBidder;

    uint public highestBid;

    mapping(address => uint) depositCashback;
    mapping(address => bool) isEligible;

    bool ended;

    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    error AuctionAlreadyEnded();
    error BidNotHighEnough(uint highestBid);
    error AuctionNotYetEnded();
    error AuctionEndAlreadyCalled();
    error IncorrectBidBondValue(uint bidBondInEthers);
    error UserIsNotEligible(address user);
    error SellerCantBeBuyer(address beneficiary);

  
    constructor(address payable _beneficiary, uint _biddingTime, uint _bidBond, string memory _hashOfAuction) {
        beneficiary = _beneficiary;
        auctionEndTime = block.timestamp + (_biddingTime * 60 seconds);
        bidBondInEthers = _bidBond * 1 ether;
        hashOfAuction = _hashOfAuction;
    }

    function deposit() public payable {
        
        if (block.timestamp > auctionEndTime)
            revert AuctionAlreadyEnded();
            
        if(msg.value * 1 ether != bidBondInEthers)
            revert IncorrectBidBondValue(bidBondInEthers);
            
        if(msg.sender == beneficiary)
            revert SellerCantBeBuyer(beneficiary);
            
        
        isEligible[msg.sender] = true;
        depositCashback[msg.sender] += msg.value;
        
    }
    
    function bid() public payable {
     
        if (block.timestamp > auctionEndTime)
            revert AuctionAlreadyEnded();

        if (msg.value <= highestBid)
            revert BidNotHighEnough(highestBid);
        
        if(isEligible[msg.sender] == false)
            revert UserIsNotEligible(msg.sender);

        if (highestBid != 0) 
            payable(highestBidder).transfer(highestBid);
     
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncreased(msg.sender, msg.value);
    
    }

    
    function withdrawBidBond() public returns (bool) {
        
        if (ended == false)
            revert AuctionNotYetEnded();
            
        if(msg.sender == highestBidder)
            depositCashback[msg.sender] = 0;
        
        uint amount = depositCashback[msg.sender];
        
        if (amount > 0) {
            depositCashback[msg.sender] = 0;

            if (!payable(msg.sender).send(amount)) {
                depositCashback[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function auctionEnd() public {
        
        if (block.timestamp < auctionEndTime)
            revert AuctionNotYetEnded();
        if (ended)
            revert AuctionEndAlreadyCalled();
       
        ended = true;
        emit AuctionEnded(highestBidder, highestBid);

        beneficiary.transfer(highestBid);
    }
}
