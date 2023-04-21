const Contracts
=artifacts.require("XycToken.sol")

const fromWei=(bn)=>{
    return web3.utils.fromWei(bn,"ether")
}
const toWei=(number)=>{
    return web3.utils.toWei(number.toString(),"ether")
}



module.exports=async function(callback){

    
    const XycToken = await Contracts.deployed()

    console.log(XycToken)

    let balanceOf= await XycToken.balanceOf("0x8E125D92c7f1Cf61925aa4c66b8C3F43627576D4")
   
    console.log("赚钱前地址token余额:"+fromWei(balanceOf))

   let result=await XycToken.transfer("0x69158fa7EF0E0fAdc431C41Ed14bbA8EF49a072B",toWei(10000),{
        from:"0x8E125D92c7f1Cf61925aa4c66b8C3F43627576D4"
    })
    console.log(result)

    let balanceOf2= await XycToken.balanceOf("0x8E125D92c7f1Cf61925aa4c66b8C3F43627576D4")
    console.log("赚钱后地址token余额:"+fromWei(balanceOf2))

    let balanceOf3= await XycToken.balanceOf("0x69158fa7EF0E0fAdc431C41Ed14bbA8EF49a072B")
    console.log("赚钱后to地址token余额:"+fromWei(balanceOf3))


    callback()
}