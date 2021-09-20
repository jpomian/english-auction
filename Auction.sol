// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract AuctionHouse {
    address [] public registeredAuctions;
    event ContractCreated(address contractAddress);
    
    function createAuction(uint _biddingTime, uint _bidBond) public {
        address newAuction = address(new Auction(payable(msg.sender), _biddingTime, _bidBond));
        emit ContractCreated(newAuction);
        registeredAuctions.push(newAuction);
    }
    
    function getDeployedAuctions() public view returns (address[] memory) {
        return registeredAuctions;
    }
}


contract Auction {
    address payable public beneficiary;
    uint public auctionEndTime;
    uint public bidBondInEthers;

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

  
    constructor(address payable _beneficiary, uint _biddingTime, uint _bidBond) {
        beneficiary = _beneficiary;
        auctionEndTime = block.timestamp + (_biddingTime * 60 seconds);
        bidBondInEthers = _bidBond * 1 ether;

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
            depositCashback[highestBidder]+=highestBid;
     
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncreased(msg.sender, msg.value);
    
    }

    
    function withdraw() public returns (bool) {
        
        if (ended == false)
            revert AuctionNotYetEnded();
        
        uint amount = depositCashback[msg.sender];
        
        if(msg.sender == highestBidder)
            amount-=highestBid;
        
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
