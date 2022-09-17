// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Auction {
 // Properties
 // 定义owner地址
 address private owner;
 uint256 public startTime;
 uint256 public endTime;
 // 映射
 mapping(address => uint256) public bids;

// 结构体
 struct House {
   string houseType;
   string houseColor;
   string houseLocation;
 }

// 最高出价，竞拍，最高价
 struct HighestBid {
   uint256 bidAmount;
   address bidder;
 }

 House public newHouse;
 HighestBid public highestBid;

 // Insert modifiers here
 // Modifiers
 // 竞拍已经结束
 modifier isOngoing() {
   require(block.timestamp < endTime, 'This auction is closed.');
   _;
 }
 // 竞拍还在进行
 modifier notOngoing() {
   require(block.timestamp >= endTime, 'This auction is still open.');
   _;
 }
 // 是不是作者，如果不是没有权限
 modifier isOwner() {
   require(msg.sender == owner, 'Only owner can perform task.');
   _;
 }
 // 不是作者
 modifier notOwner() {
   require(msg.sender != owner, 'Owner is not allowed to bid.');
   _;
 }
 // Insert events here
 // Events，允许前端调用事件
 event LogBid(address indexed _highestBidder, uint256 _highestBid);
 event LogWithdrawal(address indexed _withdrawer, uint256 amount);
 // Insert constructor and function here
 // Assign values to some properties during deployment
 constructor () {
   owner = msg.sender;
   startTime = block.timestamp;
   endTime = block.timestamp + 1 hours;
   newHouse.houseColor = '#FFFFFF';
   newHouse.houseLocation = 'Sask, SK';
   newHouse.houseType = 'Townhouse';
 }

// makeBid 开始竞价，房子必须是在拍卖中，并且不能房主自己出价
 function makeBid() public payable isOngoing() notOwner() returns (bool) {
   uint256 bidAmount = bids[msg.sender] + msg.value;
   // 当前出价要高于前面的出价，不然报错
   require(bidAmount > highestBid.bidAmount, 'Bid error: Make a higher Bid.');

   highestBid.bidder = msg.sender;
   highestBid.bidAmount = bidAmount;
   bids[msg.sender] = bidAmount;
   emit LogBid(msg.sender, bidAmount);
   return true;
 }

// 付款
 function withdraw() public notOngoing() isOwner() returns (bool) {
   uint256 amount = highestBid.bidAmount;
   bids[highestBid.bidder] = 0;
   highestBid.bidder = address(0);
   highestBid.bidAmount = 0;
  // 向房主付款
   (bool success, ) = payable(owner).call{ value: amount }("");
   require(success, 'Withdrawal failed.');
   emit LogWithdrawal(msg.sender, amount);
   return true;
 }
 // 获取最高出价
 function fetchHighestBid() public view returns (HighestBid memory) {
   HighestBid memory _highestBid = highestBid;
   return _highestBid;
 }
 // 获得当前房主
 function getOwner() public view returns (address) {
   return owner;
 }

}