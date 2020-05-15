pragma solidity ^0.6.1;

import {ERC20TokenInterface} from './IERC20.sol';
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol';

contract ERC20 is ERC20TokenInterface{
    using SafeMath for uint256;
    string internal tName;
    string internal tSymbol;
    uint256 internal tTotalSupply;
    uint256 internal  tdecimals;
    uint256 internal price;
    address internal owner;
    address internal delegatedAddres;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allownce;
    mapping(address => uint256) time;

    constructor(string memory _tokenName,string memory _symbol,uint256 _totalSupply,uint256 _decimals, uint _price)public{
        tName = _tokenName;
        tSymbol = _symbol;
        balances[msg.sender] += _totalSupply;
        tTotalSupply = _totalSupply* 10**uint256(_decimals);
        tdecimals = _decimals;
        owner = msg.sender;
        price = _price;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can call this method");
        _;
    }
    
    modifier managePrice() {
        require(msg.sender == owner || msg.sender == delegatedAddres, "you cannot update price");
        _;
    }
    
    fallback() external payable{
        send_token();
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
        balances[msg.sender] = now.add(30 days);
        // address(uint160(owner)).transfer(msg.value);
        return true;
    }
    
    function test() public payable  returns(uint,uint){
        return ((1*10**18) * 0.01, now);
    }
    
    function withdrwal_all_fund() onlyOwner payable public returns(bool){
        payable(owner).transfer(address(this).balance);
    }
    
    function delegate_address_for_price(address _addres) onlyOwner public returns(bool){
        delegatedAddres = _addres;
        return true;
    }
    
    function update_price(uint _price) public returns(bool){
        require(msg.sender == owner || msg.sender == delegatedAddres, "only special account are allowed");
        price = _price;
        return true;
    }
    
    function transfer_ownership(address _newOwner) onlyOwner public returns(bool){
        owner = _newOwner;
        return true;
    }
    
    function return_token(uint _amount) public returns(bool){
        require(balances[msg.sender] <= _amount && _amount > 0,"invailed amount");
        require(now <= balances[msg.sender], "cannot return when time is over");
        uint256 temp_price = _amount.mul(price);
        uint256 returnEtherPrice = temp_price.div(10**tdecimals);
        require(returnEtherPrice <= address(this).balance,"account doesnot have enought fund for returning you ammount");
        transfer(owner,_amount);
        address(uint160(owner)).transfer(returnEtherPrice);
        
    }
    

}