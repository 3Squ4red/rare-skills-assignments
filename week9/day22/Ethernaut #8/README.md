# Vault

Everything stored in a contract is publicly visible, even the data stored in a private variable.

The storage slots of a contract can be read externally by using javascript libraries like web3.js or ethers.js.
For example in web3.js:

`await web3.eth.getStorageAt("0x4601B8b5F80483F6b39fb29Db6bAd18117393F2B", 1)`
