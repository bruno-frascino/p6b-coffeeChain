const HDWalletProvider = require("truffle-hdwallet-provider");
 const mnemonic = "two erode truly claim album fly salad wagon book urban crawl coral"

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*" // Match any network id
    },
    rinkeby: {
      provider: function(){
        return new HDWalletProvider(mnemonic, 
          "https://rinkeby.infura.io/v3/1d68e852f03c4360be7073c383111b22");
      },
      network_id: 4,
    }
  }
  
};