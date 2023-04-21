const XycToken=artifacts.require("XycToken.sol")
const Exchange=artifacts.require("Exchange.sol")
module.exports=async function(deployer){

    let accounts =await web3.eth.getAccounts()
    await deployer.deploy(XycToken);
    
    await deployer.deploy(Exchange,accounts[0],10);
}
 