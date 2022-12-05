const RealEstate = artifacts.require("RealEstate");
const Escrow = artifacts.require("escrow");

module.exports = async function (deployer, network, accounts) {
	let a = await deployer.deploy(RealEstate);

	// deployer.deploy(Escrow, );
};
