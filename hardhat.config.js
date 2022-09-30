require("@nomicfoundation/hardhat-toolbox");

require("@nomiclabs/hardhat-etherscan");

let secret = require("./secreate")

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.7",
  networks: {
    matic:{
      url:secret.url1,
      accounts:[secret.key]
    },
    rinkeby:{
      url:secret.url,
      accounts:[secret.key]
    },
    testnet:{
      url:secret.url2,
      accounts:[secret.key]
    }
  },
  etherscan:{
    apiKey:""
  }
};
