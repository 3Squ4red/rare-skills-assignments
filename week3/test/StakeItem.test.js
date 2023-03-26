const { expect } = require("chai");

describe("stakeItem", () => {
  let stakeItem, accounts;

  beforeEach(async () => {
    accounts = await ethers.getSigners();

    const StakeItem = await ethers.getContractFactory("StakeItem");
    stakeItem = await StakeItem.connect(accounts[1]).deploy();
    await stakeItem.deployed();
  });

  describe("Deployment", () => {
    it("should set the name correctly", async () => {
      expect(await stakeItem.name())
        .to.be.a("string")
        .to.equal("Stake Item");
    });
    it("should set the symbol correctly", async () => {
      expect(await stakeItem.symbol())
        .to.be.a("string")
        .to.equal("STKI");
    });
    it("should set the owner correctly", async () => {
      expect(await stakeItem.owner())
        .to.be.a("string")
        .to.equal(accounts[1].address);
    });
  });
  describe("Minting", () => {
    it("should not let non-owner mint", async () => {
      await expect(
        stakeItem.connect(accounts[0]).safeMint(accounts[0].address, 10)
      ).to.be.revertedWith("Ownable: caller is not the owner");
    });
    it("should let the owner mint an NFT of tokenId 10 to himself", async () => {
      await stakeItem.connect(accounts[1]).safeMint(accounts[1].address, 10);
      expect(await stakeItem.ownerOf(10)).to.be.equal(accounts[1].address);
    });
  });
});
