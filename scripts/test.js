


const Contracts
=artifacts.require("StudentStorge.sol")



module.exports=async function(callback){


    const studentStorge = await Contracts.deployed()

    studentStorge.setData("xyc",18)

    let res=await studentStorge.getData()

    console.log(res)
    console.log()

    callback()
}