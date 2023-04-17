const { expect } = require("chai");

describe("GuessTheNumberChallenge", () => {
  let instance;

  beforeEach(async () => {
    const GTN = await ethers.getContractFactory("GuessTheNumberChallenge");
    instance = await GTN.deploy({ value: ethers.utils.parseEther("1.0") });
    await instance.deployed();

    // confirming if both the contracts have a balance of 1 ether
    const bal = await ethers.provider.getBalance(instance.address);
    expect(bal).to.equal(ethers.utils.parseEther("1.0"))
  });

  it("isComplete() should return true", async () => {
    // now 'guessing' with the hardcoded value 42
    await instance.guess(42, { value: ethers.utils.parseEther("1.0") });

    // checking isComplete()
    expect(await instance.isComplete()).to.be.equal(true);
  });
});
