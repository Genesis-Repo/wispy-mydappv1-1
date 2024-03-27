// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract FriendTech is ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdTracker;
    
    mapping(address => uint256) private sharePrice; // Maps user's address to the price of their share
    mapping(address => uint256) private shareSupply; // Maps user's address to the total supply of their shares
    mapping(address => mapping(address => uint256)) private userShares; // Maps user's address to the shares bought by another user
    mapping(address => mapping(uint256 => uint256)) private ownershipTimestamp; // Maps user's address to the timestamp of when they acquired a token

    event SharePriceSet(address indexed user, uint256 price);
    event ShareSupplySet(address indexed user, uint256 supply);
    event ShareBought(address buyer, address seller, uint256 sharesBought);
    event ShareSold(address seller, address buyer, uint256 sharesSold);
    event ShareTransferred(address from, address to, uint256 sharesTransferred);
    event LoyaltyRewardDistributed(address user, uint256 reward);

    constructor() ERC721("FriendTech Token", "FTT") {}

    // Set the price of the user's share
    function setSharePrice(uint256 _price) external {
        sharePrice[msg.sender] = _price;
        emit SharePriceSet(msg.sender, _price);
    }

    // Set the total supply of the user's shares
    function setShareSupply(uint256 _supply) external {
        shareSupply[msg.sender] = _supply;
        emit ShareSupplySet(msg.sender, _supply);
    }

    // Buy shares from a user
    function buyShares(address _user, uint256 _amount) external payable {
        require(sharePrice[_user] > 0, "User has not set share price");
        require(msg.value >= sharePrice[_user] * _amount, "Insufficient payment");
        
        userShares[_user][msg.sender] += _amount;
        emit ShareBought(msg.sender, _user, _amount);
    }

    // Sell shares to a user
    function sellShares(address _user, uint256 _amount) external {
        require(userShares[_user][msg.sender] >= _amount, "Insufficient shares");
        
        uint256 payment = sharePrice[_user] * _amount;
        payable(msg.sender).transfer(payment);
        userShares[_user][msg.sender] -= _amount;
        emit ShareSold(msg.sender, _user, _amount);
    }

    // Transfer shares to another user
    function transferShares(address _to, uint256 _amount) external {
        require(userShares[msg.sender][_to] >= _amount, "Insufficient shares");
        
        userShares[msg.sender][_to] -= _amount;
        userShares[_to][msg.sender] += _amount;
        emit ShareTransferred(msg.sender, _to, _amount);
    }

    // Calculate and distribute loyalty rewards based on the duration of ownership
    function distributeLoyaltyRewards() external {
        for (uint256 i = 0; i < balanceOf(msg.sender); i++) {
            uint256 tokenId = tokenOfOwnerByIndex(msg.sender, i);
            uint256 duration = block.timestamp - ownershipTimestamp[msg.sender][tokenId];
            
            // Distribute rewards based on the duration of ownership
            // Here you can define your logic for rewarding loyal token holders
            // For example, increase share supply or provide additional benefits
            uint256 reward = calculateReward(duration);
            // Add reward distribution logic here
            
            emit LoyaltyRewardDistributed(msg.sender, reward);
        }
    }

    // Function to calculate loyalty rewards based on the duration of ownership
    function calculateReward(uint256 _duration) private view returns (uint256) {
        // Add your logic to calculate rewards based on duration here
        // This can vary depending on the use case of the loyalty program
        return _duration; // Example: Reward equals the duration of ownership
    }
}