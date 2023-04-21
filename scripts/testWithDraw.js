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
    
    // // 提取前
    // res1= await exchange.tokens(ETHER_ADDRESS,accounts[0])
    // console.log(fromWei(res1))


    // await exchange.withdrawEther(toWei(5),{
    //     from:accounts[0]
    // })

    
    // //提取后
    // res1= await exchange.tokens(ETHER_ADDRESS,accounts[0])
    // console.log(fromWei(res1))

    res=await exchange.tokens(xycToken.address,accounts[0])
    console.log("前---记录用户在交易所中拥有多少个XycToken:"+fromWei(res))


    //查询交易所地址有多少个XycToken
    res =await xycToken.balanceOf(exchange.address)
    console.log("前---查询交易所地址有多少个XycToke："+fromWei(res))

    //查询交易所地址有多少个XycToken
    res =await xycToken.balanceOf(accounts[0])
    console.log("前---查询accounts[0]有多少个XycToke："+fromWei(res))


    await exchange.withdrawToken(xycToken.address,toWei(45000),{
        from:accounts[0]
     })


     res=await exchange.tokens(xycToken.address,accounts[0])
    console.log("后---记录用户在交易所中拥有多少个XycToken:"+fromWei(res))


    //查询交易所地址有多少个XycToken
    res =await xycToken.balanceOf(exchange.address)
    console.log("后---查询交易所地址有多少个XycToke："+fromWei(res))


    
    //查询交易所地址有多少个XycToken
    res =await xycToken.balanceOf(accounts[0])
    console.log("后---查询accounts[0]有多少个XycToke："+fromWei(res))


    callback()
}