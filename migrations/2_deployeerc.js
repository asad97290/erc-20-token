const ERC20 = artifacts.require("ERC20.sol");

module.exports = function(deployer) {
  deployer.deploy(ERC20,"shahzain","zain",500000000,18);
};
