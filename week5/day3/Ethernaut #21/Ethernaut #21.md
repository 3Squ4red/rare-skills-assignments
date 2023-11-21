# Shop

This exercise was simliar to the previous one as in this too, the attacker has to write a function which returns different values at different times BUT *without using any  state variable*.

## How to complete

Simply use the `isSold()` function from the Shop to determine if the `price()` has been called already. `isSold()` will return `false` if `price()` is being called the first time and `true` if `price()` is being called the second time.
