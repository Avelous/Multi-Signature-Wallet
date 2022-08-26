/* eslint-disable no-unused-vars */
// deploy/00_deploy_your_contract.js

const { ethers } = require("hardhat");

const localChainId = "31337";

// const sleep = (ms) =>
//   new Promise((r) =>
//     setTimeout(() => {
//       console.log(`waited for ${(ms / 1000).toFixed(3)} seconds`);
//       r();
//     }, ms)
//   );

module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  await deploy("MultiSigCreator", {
    from: deployer,
    log: true,
    waitConfirmations: 5,
  });

  // Getting a previously deployed contract
  const multiSigWallet = await ethers.getContract("MultiSigCreator", deployer);

  try {
    if (chainId !== localChainId) {
      await run("verify:verify", {
        address: multiSigWallet.address,
        contract: "contracts/MultiSigCreator.sol:MultiSigCreator",
        constructorArguments: [],
      });
    }
  } catch (error) {
    console.error(error);
  }
};
module.exports.tags = ["YourContract"];
