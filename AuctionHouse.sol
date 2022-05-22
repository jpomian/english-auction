// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

import "./Auction.sol";

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
