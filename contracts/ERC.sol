// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract FEMI is IERC20 {
    string public constant name = "FEM";
    string public constant symbol = "FM";
    uint8 public constant decimals = 18;

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;
    uint256 totalSupply_;

    constructor() {
        totalSupply_ = 1000;
        balances[msg.sender] = totalSupply_;
    }

    function totalSupply() public view override returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address tokenOwner) public view override returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(numTokens > 0, "Number of tokens must be greater than zero");
        require(numTokens <= balances[msg.sender], "Insufficient balance");

      //  uint256 tokensToTransfer = numTokens;
        uint256 charge = (numTokens * 10) / 100; // Calculate 10% charge
        uint256 tokensAfterCharge = numTokens;

        balances[msg.sender] = balances[msg.sender] - numTokens  - charge;
        balances[receiver] += tokensAfterCharge;

        emit Transfer(msg.sender, receiver, tokensAfterCharge);
        emit Transfer(msg.sender, address(0), charge); // Burn the charged tokens

        return true;
    }

    function approve(address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public view override returns (uint256) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[owner], "Insufficient balance");
        require(numTokens <= allowed[owner][msg.sender], "Allowance exceeded");

        // uint256 tokensToTransfer = numTokens;
        uint256 charge = (numTokens * 10) / 100; // Calculate 10% charge
        uint256 tokensAfterCharge = numTokens;

        balances[owner] = balances[owner] - numTokens  - charge;
        allowed[owner][msg.sender] = allowed[owner][msg.sender] - numTokens - charge;
        balances[buyer] += tokensAfterCharge;

        emit Transfer(owner, buyer, tokensAfterCharge);
        emit Transfer(owner, address(0), charge); // Burn the charged tokens

        return true;
    }
}
