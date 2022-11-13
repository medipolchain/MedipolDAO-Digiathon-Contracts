import { Signer } from "ethers";
import { ethers } from "hardhat";
import { expect } from "chai";

async function main() {
  let deployer;
  let governmentWallet = "0xa512abe7a9829f7131f2c29a7bef003453bd68d5";
  let municipalityWallet = "0x2be1bb42d5ad925a59a23a072bfbeedf05644c26";

  let governmentFee = 1000;
  let municipalityFee = 1000;

  [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  let kycFactory = await ethers.getContractFactory("KYC");
  let kyc = await kycFactory.connect(deployer).deploy();
  await kyc.deployed();
  console.log("KYC deployed to:", kyc.address);

  let marketPlaceFactory = await ethers.getContractFactory(
    "Marketplace",
    deployer
  );
  let marketPlace = await marketPlaceFactory
    .connect(deployer)
    .deploy(
      kyc.address,
      governmentWallet,
      municipalityWallet,
      governmentFee,
      municipalityFee
    );

  await marketPlace.deployed();
  console.log("Marketplace deployed to:", marketPlace.address);

  let eTRYFactory = await ethers.getContractFactory("eTRY", deployer);
  let eTRY = await eTRYFactory
    .connect(deployer)
    .deploy(marketPlace.address, kyc.address);

  await eTRY.deployed();
  console.log("eTRY deployed to:", eTRY.address);

  //   await marketPlace.connect(deployer).setETRY(eTRY.address);

  let fdNFTFactory = await ethers.getContractFactory("fdNFT", deployer);

  let fdNFT = await fdNFTFactory
    .connect(deployer)
    .deploy("https://turkiye.gov.tr/", kyc.address, marketPlace.address);

  await fdNFT.deployed();
  console.log("fdNFT deployed to:", fdNFT.address);
}

main();
