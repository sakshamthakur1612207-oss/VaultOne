// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title VaultOne
 * @dev Minimal ETH vault with per-user balances, using withdrawal pattern
 * @notice Users can deposit ETH and later withdraw their own funds safely
 */
contract VaultOne {
    address public owner;

    mapping(address => uint256) public balances;

    uint256 public totalDeposited;
    uint256 public totalWithdrawn;

    event Deposited(address indexed user, uint256 amount, uint256 timestamp);
    event Withdrawn(address indexed user, uint256 amount, uint256 timestamp);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Deposit ETH into the vault
     */
    function deposit() external payable {
        require(msg.value > 0, "Amount = 0");

        balances[msg.sender] += msg.value;
        totalDeposited += msg.value;

        emit Deposited(msg.sender, msg.value, block.timestamp);
    }

    /**
     * @dev Withdraw caller's available balance (full or partial)
     * @param amount Amount to withdraw
     */
    function withdraw(uint256 amount) external {
        require(amount > 0, "Amount = 0");
        uint256 bal = balances[msg.sender];
        require(bal >= amount, "Insufficient balance");

        // effects first
        balances[msg.sender] = bal - amount;
        totalWithdrawn += amount;

        (bool ok, ) = payable(msg.sender).call{value: amount}("");
        require(ok, "Transfer failed");

        emit Withdrawn(msg.sender, amount, block.timestamp);
    }

    /**
     * @dev Convenience: withdraw full balance
     */
    function withdrawAll() external {
        uint256 bal = balances[msg.sender];
        require(bal > 0, "No balance");
        balances[msg.sender] = 0;
        totalWithdrawn += bal;

        (bool ok, ) = payable(msg.sender).call{value: bal}("");
        require(ok, "Transfer failed");

        emit Withdrawn(msg.sender, bal, block.timestamp);
    }

    /**
     * @dev Get contract ETH balance
     */
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Transfer ownership of the vault
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address");
        address prev = owner;
        owner = newOwner;
        emit OwnershipTransferred(prev, newOwner);
    }
}
