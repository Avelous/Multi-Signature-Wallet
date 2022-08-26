# 🔏 Multi Signature Wallet

> off-chain based signature wallet

**Live Site**: http://multisig-sprun.surge.sh/

**Chain**: Goerli Test Network

**BuidlGuidl**: [https://buidlguidl.com/build/ehFgjAKFYGusJQy9ZEFo](https://buidlguidl.com/build/ehFgjAKFYGusJQy9ZEFo)

**Contract**: [ https://goerli.etherscan.io/address/0x1d46262fC397596019787dC87c67Ba6326d94Bab
](https://goerli.etherscan.io/address/0x1d46262fC397596019787dC87c67Ba6326d94Bab)

---

## ![Screenshot_289](https://user-images.githubusercontent.com/86206128/186980298-8f143dce-24c4-4fb7-8a3e-edd691cdb610.png)

This is a solution to challenge 5 of [SpeedrunEth](https://speedrunethereum.com/). Buidl deals with two smart contracts, a `MultisigCreator.sol` and a `MultisigWallet.sol`. The MultisigWallet can hold funds which allow access to registered wallets to propose, sign, and execute transactions. The MultisigCreator is used to create the wallet and register the signature addresses.

# 🏃‍♀️ Quick Start

> ⛳️ clone Repo

    git clone https://github.com/Avelous/Multi-Signature-Wallet.git
    cd MultiSigWallet
    yarn install
    yarn chain

> ⛳️in a second terminal window, start your 📱 frontend:

    cd MultiSigWallet
    yarn start

> ⛳️in a third terminal window, 🛰 deploy your contract:

    cd MultiSigWallet
    yarn deploy

> ⛳️in a fourth terminal window, 🗄 start your backend:

    cd MultiSigWallet
    yarn backend

---

**💡Side Notes:**

- Add an environment -`.env` file. Check the example `packages\hardhat\example.env`
- To run locally, change the default chain to local host at `packages\hardhat\hardhat.config.js`
  ![Screenshot_290](https://user-images.githubusercontent.com/86206128/186982524-64c47121-c8f9-4819-b6be-06644b30ad56.png)
- Edit the frontend network at `packages\react-app\src\App.jsx`
  ![Screenshot_292](https://user-images.githubusercontent.com/86206128/186982806-c6b26bd2-2290-4422-89de-f51232318310.png)

---

<a href="https://twitter.com/Av3lous"><img src="https://user-images.githubusercontent.com/86206128/182034124-9de8fc5b-0f4a-48b6-9a37-c2e2a0c9f8e8.svg" width="100" height="30"></a> <a href="https://www.linkedin.com/in/avelous"><img src="https://user-images.githubusercontent.com/86206128/182034127-826b3d79-4904-41e0-8897-e418973be00c.svg" width="100" height="30"></a>
