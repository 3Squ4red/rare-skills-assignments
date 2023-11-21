const { expect } = require("chai");

describe("StakeCoin", () => {
  let stakeCoin, accounts;

  beforeEach(async () => {
    accounts = await ethers.getSigners();

    const StakeCoin = await ethers.getContractFactory("StakeCoin");
    stakeCoin = await StakeCoin.connect(accounts[1]).deploy();
    await stakeCoin.deployed();
  });

  describe("Deployment", () => {
    it("should set the name correctly", async () => {
      expect(await stakeCoin.name())
        .to.be.a("string")
        .to.equal("Stake Coin");
    });
    it("should set the symbol correctly", async () => {
      expect(await stakeCoin.symbol())
        .to.be.a("string")
        .to.equal("STKC");
    });
    it("should set the owner correctly", async () => {
      expect(await stakeCoin.owner())
        .to.be.a("string")
        .to.equal(accounts[1].address);
    });
  });
  describe("Minting", () => {
    it("should not let non-owner mint", async () => {
      await expect(
        stakeCoin.connect(accounts[0]).mint(accounts[0].address, 10)
      ).to.be.revertedWith("Ownable: caller is not the owner");
    });
    it("should let the owner mint 10 tokens to himself", async () => {
      await expect(
        stakeCoin.connect(accounts[1]).mint(accounts[1].address, 10)
      ).to.changeTokenBalance(stakeCoin, accounts[1].address, 10);
    });
  });
});
