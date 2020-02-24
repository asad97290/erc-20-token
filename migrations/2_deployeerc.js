const ERC20 = artifacts.require("ERC20.sol");

module.exports = function(deployer) {
  deployer.deploy(ERC20,"shahzain","zain",5000000000000,7);
};
