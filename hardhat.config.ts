import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "dotenv/config"

const AMOY_RPC_URL = process.env.AMOY_RPC_URL || "https://polygon-amoy.g.alchemy.com/v2/zWkYwFonkIk7JMXhzkBF22QbicNAUvvG"

const PRIVATE_KEY = process.env.PRIVATE_KEY || "0xkey"


const config: HardhatUserConfig = {
  solidity: "0.8.24",
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 31337,
    },
    amoy:{
      chainId:80002,
      url:AMOY_RPC_URL,
      accounts:[PRIVATE_KEY]
    }
  },
};

export default config;
