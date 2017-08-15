var HelloWorld = artifacts.require("./HelloWorldContract.sol")
var KartikCoin = artifacts.require("./KartikCoinContract.sol")
module.exports = function(deployer) {
  deployer.deploy(HelloWorld);
  deployer.deploy(KartikCoin);
};
