const LandContract = artifacts.require("LandContract");

module.exports = function (deployer, network, accounts) {
	deployer.deploy(LandContract, accounts[0]);
};
