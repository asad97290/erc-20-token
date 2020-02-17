pragma solidity ^0.6.1;

import {ERC20Interface} from './IERC20.sol';

abstract contract ERC20 is ERC20Interface{
    string internal tName;
    string internal tSymbol;
    uint256 internal tTotalSupply;
    uint256 internal  tdecimals;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allownce;

    constructor(string memory _tokenName,string memory _symbol,uint256 _totalSupply,uint256 _decimals)public{
        tName = _tokenName;
        tSymbol = _symbol;
        balances[msg.sender] += _totalSupply;
        tTotalSupply = _totalSupply;
        tdecimals = _decimals;
    }
    function name() public view returns(string memory) { return tName;}
    function symbol() public view returns(string memory) { return tSymbol;}
    function totalsupply() public view returns(uint256) { return tTotalSupply;}
    function decimals() public view returns(uint256) { return tdecimals;}

    function balanceOf(address tokenOwner) override public view returns(uint256){ return balances[tokenOwner]; }

    function transfer(address to, uint token) override public  returns(bool success){
        require(balances[msg.sender] >= token, "you should have some token");
        balances[msg.sender] -= token;
        balances[to] += token;
        emit Transfer(msg.sender,to,token);
        return true;
    }
    function approve(address spender, uint tokens) override public returns(bool success) {
        allownce[msg.sender][spender] += tokens;
        emit Approval(msg.sender, spender,tokens);
        return true;

    }

}