const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying with address:", deployer.address);

  const NFTRental = await ethers.getContractFactory("NFTRental");
  const contract = await NFTRental.deploy();

  await contract.deployed();
  console.log("NFTRental deployed to:", contract.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
