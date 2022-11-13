import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.17",
    // settings: {
    //   optimizer: {
    //     enabled: true,
    //     runs: 200,
    //   },
    // },
  },
  networks: {
    tcsubnet: {
      url: "http://127.0.0.1:9654/ext/bc/CSUZ4ppa5z8Ldpit32QhZDPXH2JEjrh3PuENmvUKmEctF6yDn/rpc",
      accounts: [
        "0x9c70ca183d50940ec8cb25f8dfbe8ea6d75dbde809f252b1296c7a99a7b53ea1",
      ],
      chainId: 31337,
      gas: 21000000,
      blockGasLimit: 0x1fffffffffffff,
      allowUnlimitedContractSize: true,
    },

    fuji: {
      url: "https://api.avax-test.network/ext/bc/C/rpc",
      chainId: 43113,
      accounts: [
        "0x9c70ca183d50940ec8cb25f8dfbe8ea6d75dbde809f252b1296c7a99a7b53ea1",
      ],
    },

    digiathon: {
      url: "http://176.236.121.139:9656/ext/bc/C/rpc",
      chainId: 43112,
      accounts: [
        "0x9c70ca183d50940ec8cb25f8dfbe8ea6d75dbde809f252b1296c7a99a7b53ea1",
      ],
    },
  },
};

export default config;
