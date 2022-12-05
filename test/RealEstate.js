const { expect } = require("chai");
const { ethers } = require("ethers");

const RealEstate = artifacts.require("RealEstate");
const Escrow = artifacts.require("Escrow");

contract("RealEstate", function (accounts) {
	describe("RealEstate", () => {
		let realEstate, escrow;
		let deployer, seller, buyer;
		let balance;
		let nftID = 1;

		beforeEach(async () => {
			deployer = accounts[0];
			seller = deployer;
			buyer = accounts[1];

			//Deploy smart contract
			realEstate = await RealEstate.new();
			escrow = await Escrow.new(accounts[0], seller, buyer, nftID);
		});

		describe("Deployement", () => {
			it("Set NFT to seller / deployer", async () => {
				expect(await realEstate.ownerOf(nftID)).to.equal(seller);
			});
		});

		it("Selling real estate", async function () {
			//Expects seller to be NFT owner before the sale
			expect(await realEstate.ownerOf(nftID)).to.equal(seller);

			//Check escrow balance
			balance = await escrow.getBalance();
			console.log(
				"escrow balance",
				balance,
				ethers.utils.formatEther(balance.toString())
			);
		});
	});
});
