var CarRental = artifacts.require("./CarRentalContract.sol");
var StringLib = artifacts.require("./StringUtils.sol")
module.exports = function(deployer) {
  deployer.deploy(StringLib);
  deployer.link(StringLib,CarRental);
  deployer.deploy(CarRental);
};
