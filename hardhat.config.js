require("@nomiclabs/hardhat-waffle");
require('dotenv').config();

const PROJECT_ID = process.env.PROJECT_ID;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

module.exports = {
  networks: {
    hardhat: {
      chainId: 1337,
    },
    mumbai: {
      url: `https://polygon-mumbai.infura.io/v3/${PROJECT_ID}`,
      accounts: [PRIVATE_KEY]
    },
    mainnet: {
      url: `https://polygon-mumbai.infura.io/v3/${PROJECT_ID}`,
    }
  },
  solidity: "0.8.4",
};
