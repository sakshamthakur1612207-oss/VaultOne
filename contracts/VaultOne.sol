Mapping to store user balances
    mapping(address => uint256) private balances;
    
    Contract owner
    address public owner;
    
    Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    modifier hasBalance() {
        require(balances[msg.sender] > 0, "Insufficient balance");
        _;
    }
    
    /**
     * @dev Constructor sets the contract deployer as owner
     */
    constructor() {
        owner = msg.sender;
    }
    
    /**
     * @dev Deposit Ether into the vault
     * @notice Users can deposit any amount of Ether
     */
    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        
        balances[msg.sender] += msg.value;
        totalVaultBalance += msg.value;
        
        emit Deposit(msg.sender, msg.value, block.timestamp);
    }
    
    /**
     * @dev Withdraw Ether from the vault
     * @param amount The amount to withdraw
     * @notice Users can only withdraw their own deposited funds
     */
    function withdraw(uint256 amount) external hasBalance {
        require(amount > 0, "Withdrawal amount must be greater than 0");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        
        balances[msg.sender] -= amount;
        totalVaultBalance -= amount;
        
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");
        
        emit Withdrawal(msg.sender, amount, block.timestamp);
    }
    
    /**
     * @dev Check balance of caller
     * @return The balance of the caller
     * @notice Returns the amount deposited by the caller
     */
    function getBalance() external view returns (uint256) {
        return balances[msg.sender];
    }
    
    /**
     * @dev Get total vault balance
     * @return The total amount stored in the vault
     */
    function getTotalVaultBalance() external view returns (uint256) {
        return totalVaultBalance;
    }
    
    /**
     * @dev Emergency withdrawal by owner only
     * @notice Only owner can withdraw all funds in case of emergency
     */
    function emergencyWithdraw() external onlyOwner {
        uint256 amount = address(this).balance;
        require(amount > 0, "No funds to withdraw");
        
        (bool success, ) = payable(owner).call{value: amount}("");
        require(success, "Emergency withdrawal failed");
        
        emit EmergencyWithdrawal(owner, amount, block.timestamp);
    }
    
    /**
     * @dev Receive function to accept direct Ether transfers
     */
    receive() external payable {
        balances[msg.sender] += msg.value;
        totalVaultBalance += msg.value;
        emit Deposit(msg.sender, msg.value, block.timestamp);
    }
    
    /**
     * @dev Fallback function
     */
    fallback() external payable {
        revert("Invalid function call");
    }
}
// 
update
// 
