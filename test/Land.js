const { expect, assert } = require("chai");
const { ethers } = require("ethers");

const LandContract = artifacts.require("LandContract");

const token = (n) => {
	return ethers.utils.parseUnits(n.toString(), "ether");
};
const ether = token;

contract("Land", function (accounts) {
	describe("Land", () => {
		let landContract, contract;
		let owner, buyer;
		before(async () => {
			//Deploy smart contract
			landContract = await LandContract.new(accounts[0]);
			contract = await LandContract.deployed();
			console.log(
				"*******************************************************************"
			);
		});

		describe("Add land", () => {
			it("add land", async () => {
				// console.log(
				// 	"owner and land count",
				// 	await contract.owner(),
				// 	await contract.totalLandsCounter()
				// );
				owner = accounts[0];
				buyer = accounts[2];

				await contract.addLand(owner, "Pune", BigInt(ether(20)));
				await contract.addLand(owner, "Mumbai", BigInt(ether(10)));
			});

			it("getting number of lands", async () => {
				let landsCount = await contract.totalLandsCounter();
				let lands = await contract.getNoOfLands(owner);

				assert.equal(`${landsCount}`, "2", "Lands count must be 2");
				assert.equal(
					`${lands}`,
					`${landsCount}`,
					"Lands and lands count must be same"
				);
			});
		});

		describe("Transfer eth", () => {
			it("BUY", async () => {
				let land = await contract.getLandOfOwnerByLandID(1, owner);
				await contract.approve(buyer, land.landID, land.cost, {
					from: owner,
				});

				let b = await contract.buy(land, buyer);
				let contractBal = await contract.getContractBalance();
				let ownerBal = await contract.getBalance(owner);
				let buyerBal = await contract.getBalance(buyer);
				console.log("contractBal", contractBal.toString());
				console.log("ownerBal", ethers.utils.formatEther(ownerBal.toString()));
				console.log("buyerBal", ethers.utils.formatEther(buyerBal.toString()));
			});

			it("transferring ether", async () => {
				// let contractBal = await contract.getContractBalance();
				// let ownerBal = await contract.getBalance(owner);
				// let buyerBal = await contract.getBalance(buyer);
				// console.log("contractBal", contractBal.toString());
				// console.log("ownerBal", ethers.utils.formatEther(ownerBal.toString()));
				// console.log("buyerBal", ethers.utils.formatEther(buyerBal.toString()));
			});
		});

		describe("Fetch lands", () => {
			it("Fetching lands by owner", async () => {
				let lands = await contract.getLandsByOwner(owner);
				console.log(
					"Fetching lands by owner",
					lands[0].cost,
					typeof lands[0].cost
				);
			});

			it("Fetching lands by owner and index", async () => {
				let land = await contract.getLand(owner, 0);
				// console.log("Fetching lands by owner and index", land);
			});

			it("Get land buy owner and land id", async () => {
				let land = await contract.getLandOfOwnerByLandID(1, owner);
				// console.log('Get land buy owner and land id', land)
			});
		});

		describe("Transfer land", () => {
			it("transfer", async () => {
				// console.log(await contract.getLandsByOwner(owner));

				let landID = 1;

				let landBeforeTransfer = await contract.getLandOfOwnerByLandID(
					landID,
					owner
				);
				await contract.transferLand(buyer, landID);
				let landAfterTransfer = await contract.getLandOfOwnerByLandID(
					landID,
					owner
				);
				let landOfAccount2AfterTransfer = await contract.getLandOfOwnerByLandID(
					landID,
					buyer
				);

				assert.notEqual(
					landBeforeTransfer.landID,
					landAfterTransfer.landID,
					"Should not same / Land not transferred"
				);

				assert.equal(
					landOfAccount2AfterTransfer.ownerAddress,
					buyer,
					"Land tranferred successfully"
				);

				// console.log(
				// 	"account 2 >>>>>>>>>>>>>",
				// 	await contract.getLandsByOwner(buyer)
				// );
				// console.log(
				// 	"Account 0 >>>>>>>>>>>>>>>>>>>",
				// 	await contract.getLandsByOwner(owner)
				// );
			});
		});

		describe("Remove from sale", () => {
			it("remove from sale..", async () => {
				let landID = 1;
				// console.log(await contract.getLandsByOwner(buyer));
				let landBeforeTransfer = await contract.getLandOfOwnerByLandID(
					landID,
					buyer
				);

				// await contract.RemoveFromSale(buyer, landID);

				assert.notEqual(
					landBeforeTransfer.wantSell,
					"0",
					"Already not for sale"
				);

				await contract.RemoveFromSale(buyer, landID);

				let landAfterTransfer = await contract.getLandOfOwnerByLandID(
					landID,
					buyer
				);

				assert.notEqual(
					landBeforeTransfer.wantSell,
					landAfterTransfer.wantSell,
					"Not removed from sale"
				);

				// console.log(await contract.getLandsByOwner(buyer));
			});
		});
	});
});
