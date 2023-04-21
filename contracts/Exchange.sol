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

    //订单结构体
    //订单结构体
    struct _Order {
        uint256 id;
        address user;
        address tokenGet;
        uint256 amountGet;

        address tokenGive;
        uint256 amountGive;

        uint256 timestamp;
    }


    //订单 列表
    mapping(uint256=>_Order) public orders;

    //订单数量

    uint256 public orderCount;



    //存储订单是否取消
    mapping(uint256=>bool) public orderCancel;

    //存储订单是否交易
    mapping(uint256=>bool) public orderFill;

    event Deposit(address tokenType,address user, uint value ,uint256 balance);
    event WithDraw(address tokenType,address user, uint value ,uint256 balance);
    //创建订单事件
    event Order(
        uint256 id,
        address user,
        address tokenGet,
        uint256 amountGet,
        address tokenGive,
        uint256 amountGive,
        uint256 timestamp
    );

    //取消订单事件
    event Cancel(
        uint256 id,
        address user,
        address tokenGet,
        uint256 amountGet,
        address tokenGive,
        uint256 amountGive,
        uint256 timestamp
    );

    //填充订单
    
    event Trade(
            uint256 id,
            address user,
            address fillUser,
            address tokenGet,
            uint256 amountGet,
            address tokenGive,
            uint256 amountGive,
            uint256 timestamp
        );

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

    //查余额
    function balanceOf(address _token,address _user) public view returns (uint256) {
        return tokens[_token][_user];
    }
    
    //makeOrder
    //_tokenGive 出多少xxxToken   获取多少 xxx_token
    function makeOrder(address _tokenGet,
        uint256 _amountGet,
        address _tokenGive,
        uint256 _amountGive) public 
        {
        require(balanceOf(_tokenGive,msg.sender)>=_amountGive,unicode"创建订单时余额不足");
        orderCount = orderCount.add(1);
        orders[orderCount] = _Order(orderCount,msg.sender,_tokenGet,_amountGet,_tokenGive,_amountGive,block.timestamp);
        //发出订单
        emit Order(orderCount,msg.sender,_tokenGet,_amountGet,_tokenGive,_amountGive,block.timestamp);
    }


    //cancel 取消订单
    //cancelOrder
    function cancelOrder(uint256 _id) public {
        _Order memory myorder = orders[_id];
        require(myorder.user==msg.sender);
        require(myorder.id == _id);
        orderCancel[_id] = true;
        emit Cancel(myorder.id,msg.sender,myorder.tokenGet,myorder.amountGet,myorder.tokenGive,myorder.amountGive,block.timestamp);
    }
    

    //填充订单
    function fillOrder(uint256 _id)public{

        _Order memory myorder = orders[_id];
       
        require(myorder.id == _id);

        orderFill[_id] = true;

        //msg.sender,

        //假如有一个订单
        //用tokenGet  换取一定数量的 tokenGive


        //小费计算，填充订单的人支付
        uint256 feeAmout = myorder.amountGet.mul(feePercent).div(100);


        require(balanceOf(myorder.tokenGet, msg.sender)>=myorder.amountGet.add(feeAmout),unicode"填充订单的人余额不足");
        require(balanceOf(myorder.tokenGive, myorder.user)>=myorder.amountGive,unicode"创建订单的人余额不足");

        tokens[myorder.tokenGet][msg.sender]=tokens[myorder.tokenGet][msg.sender].sub(myorder.amountGet.add(feeAmout));
        tokens[myorder.tokenGet][myorder.user]=tokens[myorder.tokenGet][myorder.user].add(myorder.amountGet);


        //转账到freeAccount
         tokens[myorder.tokenGet][feeAccount] = tokens[myorder.tokenGet][feeAccount].add(feeAmout);


        
        tokens[myorder.tokenGive][msg.sender]=tokens[myorder.tokenGive][msg.sender].add(myorder.amountGive);
        tokens[myorder.tokenGive][myorder.user]=tokens[myorder.tokenGive][myorder.user].sub(myorder.amountGive);




        emit Trade(myorder.id,myorder.user,msg.sender,myorder.tokenGet,myorder.amountGet,myorder.tokenGive,myorder.amountGive,block.timestamp);
    }


        



}