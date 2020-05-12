pragma solidity ^0.6.1;

import {ERC20TokenInterface} from './IERC20.sol';

contract ERC20 is ERC20TokenInterface{
    string internal tName;
    string internal tSymbol;
    uint256 internal tTotalSupply;
    uint256 internal  tdecimals;
    uint256 internal price = 100000000000000;
    address internal owner;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allownce;

    constructor(string memory _tokenName,string memory _symbol,uint256 _totalSupply,uint256 _decimals)public{
        tName = _tokenName;
        tSymbol = _symbol;
        balances[msg.sender] += _totalSupply;
        tTotalSupply = _totalSupply* 10**uint256(_decimals);
        tdecimals = _decimals;
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can call this method");
        _;
    }
    
    function name() override public view returns(string memory) { return tName;}
    function symbol() override public view returns(string memory) { return tSymbol;}
    function totalSupply()override  public view returns(uint256) { return tTotalSupply;}
    function decimals() override public view returns(uint256) { return tdecimals;}

    function balanceOf(address tokenOwner) override public view returns(uint256){ return balances[tokenOwner]; }

    function transfer(address to, uint token) override public  returns(bool success){
        require(balances[msg.sender] >= token, "you should have some token");
        balances[msg.sender] -= token;
        balances[to] += token;
        emit Transfer(msg.sender,to,token);
        return true;
    }
    function approve(address spender, uint tokens) override public returns(bool success) {
        require((tokens == 0) || (allownce[msg.sender][spender] == 0));
        allownce[msg.sender][spender] += tokens;
        emit Approval(msg.sender, spender,tokens);
        return true;

    }
    function allowance(address _owner, address spender) override public view returns(uint){
        return allownce[_owner][spender];
    }
    function transferFrom(address from, address to, uint tokens) override public returns(bool success) {
        require(balances[from] >= tokens);
        require(allownce[from][msg.sender] >= tokens);
        balances[from] -= tokens;
        balances[to] += tokens;
        allownce[from][msg.sender] -= tokens;
        emit Transfer(from,to,tokens);
        return true;
        
    }
    
    function send_token()  public payable returns(bool) {
        require(msg.value > 0 ether, "invailed amount");
        require(tx.origin == msg.sender,"should be external owned account");
        uint wei_unit = (1*10**18)/price;
        uint final_price = msg.value * wei_unit;
        balances[owner] -= final_price;
        balances[msg.sender] += final_price;
        address(uint160(owner)).transfer(msg.value);
        return true;
    }

}