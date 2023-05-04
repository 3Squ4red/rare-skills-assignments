# Recovery

We are supposed to drain the token contract of all its ether (0.001). But the problem is, its address is unknown. So we have to figure out two things:

1. The address of the token contract
2. How to take all the ether from it

The second problem has an easy solution: there's a `destroy(address payable)` which is public and without any caller restrictions.

As for the first problem, 
