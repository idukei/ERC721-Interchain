const { ethers } = require("hardhat");
require("dotenv").config({ path: ".env" });
const { WHITELIST_CONTRACT_ADDRESS, METADATA_URL } = require("../constants");
const { DEPLOYED_ERC721_CONTRACT_ADDRESS } = require("../constants");


async function main() {
  // Address of the whitelist contract that you deployed in the previous module
  const whitelistContract = WHITELIST_CONTRACT_ADDRESS;

  // URL from where we can extract the metadata for a Crypto Dev NFT
  const metadataURL = METADATA_URL;

  const boletokenContract = await ethers.getContractFactory("Boletoken");//ethers factory

  // deploy the contract
  const deployedboletokenContract = await boletokenContract.deploy(
    metadataURL,
    whitelistContract
  );

  // print the address of the deployed contract
  console.log(
    "Crypto Devs Contract Address:",
    deployedboletokenContract.address
  );

  // Deploy Collateral Wraped ERC721 //


// Deploy Collateral
const boleTosCollateralContract = await ethers.getContractFactory(
  "BoletokenInterchain"
  );

// deploy the contract
const deployedInterchainboletosContract = await boleTosCollateralContract.deploy(
  DEPLOYED_ERC721_CONTRACT_ADDRESS);
}

console.log(
"BoletosInterchain Contract Address:",
deployedInterchainboletosContract.address
);

// Call the main function and catch if there is any error
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
