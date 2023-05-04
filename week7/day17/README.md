# Delete User

## How to complete

1. Call `deposit()` with 1 ether
2. Call `deposit()` without any ether
3. Call `withdraw(1)` i.e. with 1 as a parameter
4. Call `withdraw(1)` again

We are able to withdraw twice at the same index because:
On line 26, `user = users[users.length - 1];`, it looks like the struct stored at index 1 is being overridden by the struct stored at the last index (2). At least, *this* is what its author must have intended to do.

However, reference variables (i.e. non-value type variables) do not hold actual data, but a *reference* (or a pointer) to that data. Therefore, on line 26, instead of the actual struct (at the last index), just a reference to that is being stored at the `user` variable.

So, we can call withdraw twice at the same index and drain its balance.
