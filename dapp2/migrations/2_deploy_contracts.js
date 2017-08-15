var KartikCoin = artifacts.require("./KartikCoinContract.sol");

module.exports = function(deployer) {
  deployer.deploy(KartikCoin);
};
