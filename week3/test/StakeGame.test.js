const { time } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");

describe("StakeGame", () => {
  let stakeItem, stakeGame, stakeCoin, accounts;
  const TOKEN_ID = 99;
  const ONE_DAY_IN_SEC = 60 * 60 * 24;

  beforeEach(async () => {
    accounts = await ethers.getSigners();

    // Deploy the nft first
    const StakeItem = await ethers.getContractFactory("StakeItem");
    stakeItem = await StakeItem.deploy();
    await stakeItem.deployed();

    // Deploying the game next
    const StakeGame = await ethers.getContractFactory("StakeGame");
    stakeGame = await StakeGame.deploy(stakeItem.address);
    await stakeGame.deployed();

    // saving the stake coin contract
    const StakeCoin = await ethers.getContractFactory("StakeCoin");
    stakeCoin = await StakeCoin.attach(await stakeGame.stakeCoin());
  });

  async function mintAndStakeNFT() {
    // mint an NFT of id 99 to accounts[0]
    await stakeItem.safeMint(accounts[0].address, TOKEN_ID);

    // transfer this NFT to StakeGame
    stakeItem["safeTransferFrom(address,address,uint256)"](
      accounts[0].address,
      stakeGame.address,
      TOKEN_ID
    );
    const lastClaimTime = await stakeGame.lastClaimTimeOf(TOKEN_ID);
    return lastClaimTime;
  }

  describe("Deployment", () => {
    it("should deploy StakeCoin automatically", async () => {
      const stakeCoinAddress = await stakeGame.stakeCoin();
      expect(stakeCoinAddress).to.not.be.equal(ethers.constants.AddressZero);
    });
    it("should set the NFT address correctly", async () => {
      expect(await stakeGame.stakeItem()).to.be.equal(stakeItem.address);
    });
  });

  describe("Staking", () => {
    it("should revert on staking another NFT", async () => {
      // deploying another NFT
      const StakeItem2 = await ethers.getContractFactory("StakeItem");
      const stakeItem2 = await StakeItem2.deploy();
      await stakeItem2.deployed();

      // minting an nft of id 99 to accounts[0]
      await stakeItem2.safeMint(accounts[0].address, TOKEN_ID);

      await expect(
        stakeItem2["safeTransferFrom(address,address,uint256)"](
          accounts[0].address,
          stakeGame.address,
          TOKEN_ID
        )
      ).to.be.revertedWith("StakeGame: must send STKI only");
    });
    it("should not revert and record staked NFT", async () => {
      // mint an nft of id 99 to accounts[0]
      await stakeItem.safeMint(accounts[0].address, TOKEN_ID);

      // now send the minted nft to StakeGame
      await expect(
        stakeItem["safeTransferFrom(address,address,uint256)"](
          accounts[0].address,
          stakeGame.address,
          TOKEN_ID
        )
      ).to.not.be.reverted;

      // checking state changes
      const currentTime = await time.latest();
      expect(await stakeGame.lastClaimTimeOf(TOKEN_ID)).to.be.approximately(
        currentTime,
        5
      );
      expect(await stakeGame.stakerOf(TOKEN_ID)).to.be.equal(
        accounts[0].address
      );
    });
  });

  describe("Claiming reward", () => {
    it("should not let non-staker claim reward for an NFT", async () => {
      await mintAndStakeNFT();

      await expect(
        stakeGame.connect(accounts[1]).claim(TOKEN_ID)
      ).to.be.revertedWith("StakeGame: caller is not the staker");
    });
    it("should not let staker claim rewards within 24 hours of staking", async () => {
      const lastClaimTime = await mintAndStakeNFT();

      await expect(stakeGame.claim(TOKEN_ID))
        .to.be.revertedWithCustomError(stakeGame, "EarlyClaimError")
        .withArgs(lastClaimTime.toNumber() + ONE_DAY_IN_SEC);
    });
    it("reward and next claim time should be 0 for unstaked NFT", async () => {
      const { tokenReward, nextClaimTime } = await stakeGame.getClaimReward(
        TOKEN_ID + 1
      );
      expect(tokenReward).to.be.equal(0);
      expect(nextClaimTime).to.be.equal(0);
    });
    it("should let staker claim 20 tokens after 48 hours", async () => {
      await mintAndStakeNFT();

      await time.increase(ONE_DAY_IN_SEC * 2);

      await expect(stakeGame.claim(TOKEN_ID)).to.changeTokenBalance(
        stakeCoin,
        accounts[0].address,
        ethers.utils.parseEther("20")
      );

      expect(await stakeGame.lastClaimTimeOf(TOKEN_ID)).to.be.approximately(
        await time.latest(),
        5
      );
    });
  });
  describe("Withdrawing NFT", () => {
    it("should not let non-staker withdraw his NFT", async () => {
      await mintAndStakeNFT();

      await expect(
        stakeGame.connect(accounts[1]).withdraw(TOKEN_ID)
      ).to.be.revertedWith("StakeGame: caller is not the staker");
    });
    it("should let staker withdraw his NFT without reward", async () => {
      await mintAndStakeNFT();

      // staker should not receive any token reward
      await expect(stakeGame.withdraw(TOKEN_ID)).to.changeTokenBalance(
        stakeCoin,
        accounts[0].address,
        0
      );

      // state variables should get updated
      expect(await stakeGame.stakerOf(TOKEN_ID)).to.be.equal(
        ethers.constants.AddressZero
      );
      expect(await stakeGame.lastClaimTimeOf(TOKEN_ID)).to.be.equal(0);

      // staker should get back his NFT
      expect(await stakeItem.ownerOf(TOKEN_ID)).to.be.equal(
        accounts[0].address
      );
    });
    it("should let staker withdraw his NFT with reward", async () => {
      await mintAndStakeNFT();

      await time.increase(ONE_DAY_IN_SEC * 10);

      // staker should receive 10 token reward
      await expect(stakeGame.withdraw(TOKEN_ID)).to.changeTokenBalance(
        stakeCoin,
        accounts[0].address,
        ethers.utils.parseEther("100")
      );

      // state variables should get updated
      expect(await stakeGame.stakerOf(TOKEN_ID)).to.be.equal(
        ethers.constants.AddressZero
      );
      expect(await stakeGame.lastClaimTimeOf(TOKEN_ID)).to.be.equal(0);

      // staker should get back his NFT
      expect(await stakeItem.ownerOf(TOKEN_ID)).to.be.equal(
        accounts[0].address
      );
    });
  });
});
