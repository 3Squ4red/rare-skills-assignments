# Selfie

We have to drain the `SelfiePool` of all of its DVTs (1.5 million) which is an ERC20 token with snapshots.
There's a function called `emergencyExit(address)`  which sends all the pool's token to an address.

BUT! This function can only be called by the `SimpleGovernance` contract.
So, let's shift our focus to it.

To call an external function from `SimpleGovernance`, we can use the `executeAction(uint256)` function in it.
It takes in an `actionId` and executes a corresponding action present in the `_actions` mapping ONLY if it was queued at least 2 days ago and if it hasn't been executed already.
Now, to queue an action, an account must have enough votes i.e. it must have more DVT than half of its total supply AT THE LAST SNAPSHOT.

We don't have any DVT with us, BUT! we can get them as a flash loan from the `SelfiePool`;
take a snapshot; repay the flash loan; then queue an action on the `SimpleGovernance` to call the `emergencyExit(address)`
function on the `SelfiePool` with our address as the parameter.

Finally, after 2 days, we can simply call the `executeAction(uint)` with the `actionId` of our queued action (which will be 1);
