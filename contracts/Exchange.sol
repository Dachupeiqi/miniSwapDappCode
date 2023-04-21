// SPDX-License-Identifier: GPL-3.0 
// 源码遵循协议， MIT...
pragma solidity >=0.4.16 <0.9.0; //限定solidity编译器版本
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./XycToken.sol";
contract Exchange{
    using SafeMath for uint256;

    //收费账号地址(交易成功抽成地址)
    address public feeAccount; 
    uint256 public feePercent;

    //代表以太坊数组下标常量
    address constant ETHER =address(0);
    
    //币类型=》账号地址=》数量
    mapping (address=>mapping(address=>uint256)) public tokens;

    event Deposit(address tokenType,address user, uint value ,uint256 balance);
    event WithDraw(address tokenType,address user, uint value ,uint256 balance);

    constructor(address _feeAccount ,uint256 _feePercent){
        feeAccount=_feeAccount;
        feePercent=_feePercent;
    }

    //用户往交易所合约地址存以太币
    function depositEther() payable public {
        //存以太币
        tokens[ETHER][msg.sender]=tokens[ETHER][msg.sender].add(msg.value);
        emit Deposit(ETHER,msg.sender,msg.value,tokens[ETHER][msg.sender]);
    }

    //用户往交易所合约地址其他Token
    function depositToken(address _token,uint256 _amount) public {
        require(_token!=ETHER);

        //调用第三方Token得往当前交易所转Token
        require( XycToken(_token).transferFrom(msg.sender,address(this),_amount)  );

        tokens[_token][msg.sender]=tokens[_token][msg.sender].add(_amount);

        emit Deposit(_token,msg.sender,_amount,tokens[_token][msg.sender]);
    }


    //提取以太币
    function withdrawEther(uint256 _amount) public{

        require(tokens[ETHER][msg.sender]>=_amount);

        tokens[ETHER][msg.sender]=tokens[ETHER][msg.sender].sub(_amount);

        payable(msg.sender).transfer(_amount);

        emit  WithDraw(ETHER, msg.sender,_amount, tokens[ETHER][msg.sender]);
        
    }

    //提取XYCTK
    function withdrawToken(address _token, uint _amount) public{
        require(_token!=ETHER);
        require(tokens[_token][msg.sender]>=_amount);

        tokens[_token][msg.sender]=tokens[_token][msg.sender].sub(_amount);

        //退给msg.sender
        require(XycToken(_token).transfer(msg.sender, _amount));
        
        emit  WithDraw(_token, msg.sender,_amount, tokens[_token][msg.sender]);
    }



    


        



}