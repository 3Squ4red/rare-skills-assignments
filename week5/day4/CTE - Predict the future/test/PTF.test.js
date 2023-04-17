const { expect } = require("chai");

describe("PredictTheFutureChallenge", () => {
  let instance, solution;

  beforeEach(async () => {
    const PTFC = await ethers.getContractFactory("PredictTheFutureChallenge");
    instance = await PTFC.deploy({ value: ethers.utils.parseEther("1.0") });
    await instance.deployed();

    const Solution = await ethers.getContractFactory("Solution");
    solution = await Solution.deploy(instance.address, 6);
    await solution.deployed();
  });

  it("isComplete() should return true", async () => {
    // lock in a guess of 6, which was set at the time of deployment
    await solution.lockInGuess({ value: ethers.utils.parseEther("1.0") });

    // try attacking
    while (!(await instance.isComplete())) {
      try {
        await solution.attack();
      } catch (e) {
        continue;
      }
    }

    expect(await instance.isComplete()).to.be.true;
  });
});
