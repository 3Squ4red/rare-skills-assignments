# Denial

It was similar to `King`, with the only difference being that in `King`, `transfer` function (which sends only 23000 gas) was used to transfer the funds over to the previous king, while in this challenge, `call` (which sends all the gas) is used to transfer the funds to the `partner` *and* it's not being checked whether the funds got successfully transferred or not.

Because of this, we cannot simply omit the `receive` or `fallback` function (or just call `revert()` in them) in our contract in order to prevent the owner from withdrawing.

Instead, we can use the `INVALID` opcode (by calling `invalid()` in an `assembly` block) in our `receive` or `fallback` function which would consume all the gas given to it, and hence, no gas would be left to update the state variables (or to send the funds to the owner).
