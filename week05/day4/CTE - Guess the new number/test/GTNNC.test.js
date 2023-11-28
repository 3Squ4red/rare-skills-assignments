const { expect } = require("chai");

describe("GuessTheNewNumberChallenge", () => {
  let instance, solution;

  beforeEach(async () => {
    const GTNNC = await ethers.getContractFactory("GuessTheNewNumberChallenge");
    instance = await GTNNC.deploy({ value: ethers.utils.parseEther("1.0") });
    await instance.deployed();

    const Solution = await ethers.getContractFactory("Solution");
    solution = await Solution.deploy();
    await solution.deployed();
  });

  it("isComplete() should return true", async () => {
    // call solve on the solution passing 1 ether
    await solution.solve(instance.address, {
      value: ethers.utils.parseEther("1.0"),
    });

    // now check isComplete()
    expect(await instance.isComplete()).to.be.true;
  });
});
