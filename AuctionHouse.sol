// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract AuctionHouse {

    // Owner address
    address public owner;

    
    string public houseName;
    uint public adminID;
    uint public launchDate;

    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

   
    constructor(address _owner, string memory _houseName, uint _adminID, uint _date) {
        // TODO: Assert statements for year, month, day
        owner = _owner;
        houseName = _houseName;
        adminID = _adminID;
        launchDate = _date; 
    }

    function giveTip() public payable {
        
    }

    
    function collect() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

   
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
    
    
    function getHouseDetails() public view returns (
        address, string memory, uint, uint) {
        return (
            owner,
            houseName,
            adminID,
            launchDate
        );
    }
}
