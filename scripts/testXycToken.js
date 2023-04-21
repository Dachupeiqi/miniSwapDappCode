const Contracts
=artifacts.require("XycToken.sol")


module.exports=async function(callback){

    
    const XycToken = await Contracts.deployed()

    console.log(XycToken)

    let decimal= await XycToken.decimals()
    let total= await XycToken.totalSupply()
    console.log(total)

    callback()
}