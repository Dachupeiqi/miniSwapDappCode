const XycToken
=artifacts.require("XycToken.sol")
const Exchange
=artifacts.require("Exchange.sol")

const fromWei=(bn)=>{
    return web3.utils.fromWei(bn,"ether")
}
const toWei=(number)=>{
    return web3.utils.toWei(number.toString(),"ether")
}



module.exports=async function(callback){

    const xycToken=await XycToken.deployed()
    const exchange=await Exchange.deployed()

    const accounts=await web3.eth.getAccounts()
    console.log(accounts)
    const ETHER_ADDRESS = '0x0000000000000000000000000000000000000000' // 0x 后面 40 个 0
    
    // //往交易所存以太币
    await exchange.depositEther({
        from:accounts[0],
        value:toWei(10)
    })

    // //查询某个账户在交易所合约里存了多少以太币
    res1= await exchange.tokens(ETHER_ADDRESS,accounts[0])
    console.log(fromWei(res1))
    


    //往合约存XycToken

    //授权1000000给交易所
    await xycToken.approve(exchange.address,toWei(100000),{
        from:accounts[0],
    })

     //查询交易所合约地址有多少授权XycToken
    res=await xycToken.allowance(accounts[0],exchange.address)
     console.log("查询交易所合约地址有多少授权XycToken:"+fromWei(res))

    //授权完调用交易所强制把XycToken转到交易所地址，并记录用户在交易所中拥有多少个XycToken
    await exchange.depositToken(xycToken.address,toWei(60000),{
        from:accounts[0]
    })

     
    res=await exchange.tokens(xycToken.address,accounts[0])
    console.log("记录用户在交易所中拥有多少个XycToken:"+fromWei(res))



       //查询还剩多少授权额度
        res=await xycToken.allowance(accounts[0],exchange.address)
       console.log("查询还剩多少授权额度:"+fromWei(res))
   

       //查询交易所地址有多少个XycToken
       res =await xycToken.balanceOf(exchange.address)
       console.log("查询交易所地址有多少个XycToke："+fromWei(res))


    callback()
}