const { expect } = require("chai");

describe("PredictTheBlockHashChallenge", () => {
  let instance;
  beforeEach(async () => {
    const PTBHC = await ethers.getContractFactory(
      "PredictTheBlockHashChallenge"
    );
    instance = await PTBHC.deploy({ value: ethers.utils.parseEther("1.0") });
    await instance.deployed();
  });

  it("isComplete() should return true", async () => {
    // lock in guess with 0x0000000000000000000000000000000000000000000000000000000000000000
    await instance.lockInGuess(
      "0x0000000000000000000000000000000000000000000000000000000000000000",
      { value: ethers.utils.parseEther("1.0") }
    );

    // mine 257 blocks
    const initBlockNumber = await ethers.provider.getBlockNumber();
    let lastBlockNumber = initBlockNumber;
    do {
      lastBlockNumber = await ethers.provider.getBlockNumber();
      await ethers.provider.send("evm_mine", []);
    } while (lastBlockNumber - initBlockNumber < 256);
    
    // call settle()
    await instance.settle();

    expect(await instance.isComplete()).to.be.true;
  });
});
