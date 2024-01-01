const { ethers, upgrades } = require("hardhat");

async function main() {
  const [owner] = await ethers.getSigners();

  // deploying PrimeNFT
  const PrimeNFT = await ethers.getContractFactory("PrimeNFT");
  const nft = await upgrades.deployProxy(PrimeNFT);
  await nft.waitForDeployment();
  console.log("PrimeNFT deployed to:", await nft.getAddress());

  // Deploying StakeCoin
  const StakeCoin = await ethers.getContractFactory("StakeCoin");
  const coin = await upgrades.deployProxy(StakeCoin, [owner.address]);
  await coin.waitForDeployment();
  console.log("StakeCoin deployed to:", await coin.getAddress());

  // Deploying StakeGame
  const StakeGame = await ethers.getContractFactory("StakeGame");
  const game = await upgrades.deployProxy(StakeGame, [await nft.getAddress()]);
  await game.waitForDeployment();
  console.log("StakeGame deployed to:", await game.getAddress());
}

main();

/**

PrimeNFT deployed to: 0x5685FFDD1157DD9EdE1c88337Fd1e5d092da59ba
StakeCoin deployed to: 0xA2fACBBc330Fc4e4625132781c38Efc8C5f8952c
StakeGame deployed to: 0x4b241e8232D4C67D057578b00EE32c540F0Fea9A

 */
