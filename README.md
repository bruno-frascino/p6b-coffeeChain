# Decentralized Coffee Supply Chain

This is an Ethereum DApp that demonstrates the stages of the Coffee Supply Chain since the harvesting of the beans by the Grower till the end consumer. Each step of the production is registered, the beans are harvested and prepared for sale by the grower, intermediaries will buy them and resell them to roasters which will process them and sell them to retailers so it can reach the end consumer.

## Dependencies

Node.js            v10.15.1
Ganache-CLI        v6.1.8
Truffle            v4.1.14
Metamask           Chrome extension

## Installation

Install:

- Node.js from https://nodejs.org/en/
- Truffle suite from https://truffleframework.com/ganache
- Metamask - Search and install it on chrome://extensions/

Clone this project and inside the project's folder, on a Terminal window install project's packages: 

```
npm i
```

## Running the Front End to Interact with the Smart Contract

On a Terminal window, run your Ethereum client, Ganache-cli, with your account mnemonic:

```
ganache-cli -m 'mars pluto saturn... (12 word menmonic seed phrase)'
```

Run your Lite-Server to be able to interact with the smart contract:

```
npm run dev
```

Access the URL address: 

http://localhost:3000

Connect to Metamask and let the app connect to your metamask address. Then select `Rinkeby Test Network` from the dropdown menu at the top.

Now your are ready to use to interact with the system.

## Running Tests

Make sure your ganache-cli is running, you need an Ethereum client to run the tests, if you need to start it just on a Terminal window run: 

```
ganache-cli
```

Now you can run the tests, on a Terminal window, go to the project folder and run: 

```
truffle test
```

