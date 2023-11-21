# The Rewarder

We have to get as many `RewardToken`s into our account as many possible. `TheRewarderPool` is giving out `RewardToken`(s) to anyone who's depositing DVTs into it.

We don't have any DVTs with us but there's also a `FlashLoanerPool` which is giving out flash loans of DVT.

So, we'll have to write a contract that will get a flash loan of all the DVTs in the `FlashLoanerPool`, deposit the DVTs into `TheRewarderPool` (getting the `RewardToken`s), withdraw back the DVTs, and finally pay back the DVT flash loan.

Now that our contract has the `RewardToken`s, just send them to your address.
