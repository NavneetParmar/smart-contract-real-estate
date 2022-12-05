const { expect } = require("chai");
const { ethers } = require("ethers");

const LandContract = artifacts.require("LandContract");

const token = (n) => {
	return ethers.utils.parseUnits(n.toString(), "ether");
};
const ether = token;

contract("Land", function (accounts) {
	describe("Land", () => {
		let landContract, contract;
		beforeEach(async () => {
			//Deploy smart contract
			landContract = await LandContract.new();
			contract = await LandContract.deployed();
		});

		describe("Add land", () => {
			it("add land", async () => {
				await contract.MyLandContract();
				// console.log(
				// 	"owner and land count",
				// 	await contract.owner(),
				// 	await contract.totalLandsCounter()
				// );

				await contract.addLand(accounts[0], "Pune", 20);
				await contract.addLand(accounts[0], "Mumbai", 10);
			});
		});

		describe("Fetch lands", () => {
			it("Fetching lands by owner", async () => {
				let lands = await contract.getLandsByOwner(accounts[0]);
				// console.log("land", lands);
			});

			it("Fetching lands by owner and index", async () => {
				let land = await contract.getLand(accounts[0], 0);
				// console.log("land", land);
			});
		});

		describe("Transfer land", () => {
			it("transfer", async () => {
				// console.log(await contract.getLandsByOwner(accounts[0]));

				let lands = await contract.transferLand(accounts[2], 1);

				// console.log(
				// 	"account 2 >>>>>>>>>>>>>",
				// 	await contract.getLandsByOwner(accounts[2])
				// );
				// console.log(
				// 	"Account 0 >>>>>>>>>>>>>>>>>>>",
				// 	await contract.getLandsByOwner(accounts[0])
				// );
			});
		});

		describe("Remove from sale", () => {
			it("remove from sale..", async () => {
				console.log(await contract.getLandsByOwner(accounts[2]));

				let ans = await contract.RemoveFromSale(accounts[2], 1);
				console.log(await contract.getLandsByOwner(accounts[2]));
				// let a = await contract.RemoveFromSale(accounts[2], 1);
			});
		});

		describe("Get number of lands", () => {
			it("getting number of lands", async () => {
				let lands = await contract.getNoOfLands(accounts[0]);
				console.log("lands", lands);
			});
		});
	});
});
