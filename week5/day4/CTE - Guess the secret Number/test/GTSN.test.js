const { expect } = require("chai");

describe("GuessTheSecretNumberChallenge", () => {
  const ANSWER_HASH =
    "0xdb81b4d58595fbbbb592d3661a34cdca14d7ab379441400cbfa1b78bc447c365";
  let instance;

  beforeEach(async () => {
    const GTSN = await ethers.getContractFactory(
      "GuessTheSecretNumberChallenge"
    );
    instance = await GTSN.deploy({ value: ethers.utils.parseEther("1.0") });
    await instance.deployed();
  });

  it("isComplete() should return true on successfully solving", async () => {
    for (let i = 0; i < 256; i++) {
      const hash = ethers.utils.keccak256([i]);
      if (hash == ANSWER_HASH) {
        console.log("ANSWER!!!!! IS ", i);

        await instance.guess(i, { value: ethers.utils.parseEther("1.0") });
        break;
      }
    }

    expect(await instance.isComplete()).to.be.true;
  });
});
