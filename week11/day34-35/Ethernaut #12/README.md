Figuring out the correct slot number of `data[2]`:

```java
// SLOT 0
bool public locked = true;
// SLOT 1
uint256 public ID = block.timestamp;
// SLOT 2 (packed together to save space)
uint8 private flattening = 10;
uint8 private denomination = 255;
uint16 private awkwardness = uint16(block.timestamp);
// SLOT 3-5 ( (slot-index) 3-0, 4-1, 5-2)
bytes32[3] private data;
```

Open the console and run the following:

```js
await web3.eth.getStorageAt(contract.address, 5)
```

This will get us the `data[2]` which is the `_key` to the `unlock` function.

Now, this data is in `bytes32` format. To convert it to `byte16`, just remove the last 32 characters.