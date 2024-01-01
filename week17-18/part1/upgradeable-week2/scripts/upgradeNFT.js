// scripts/upgrade-box.js
const { ethers, upgrades } = require("hardhat");

async function main() {
  const [owner] = await ethers.getSigners();
  const NFT_ADDRESS = "0x5685FFDD1157DD9EdE1c88337Fd1e5d092da59ba";

  const PrimeNFTV2 = await ethers.getContractFactory("PrimeNFTV2");
  await upgrades.upgradeProxy(NFT_ADDRESS, PrimeNFTV2, {
    call: { fn: "initializeV2", args: [owner.address] },
  });
  console.log("PrimeNFT upgraded");
}

main();
