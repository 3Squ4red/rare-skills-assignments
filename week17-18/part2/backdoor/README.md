# Backdoor

In this challenge, the `GnosisSafeProxy` is sent 10 DVT tokens every time a *beneficiary* (Alice, Bob, Charlie and David) creates it. Our job is to steal away the DVT tokens for all the beneficiaries, i.e. 40 DVTs.

# How to complete

The `GnosisSafeProxyFactory` (in the `createProxyWithCallback` function) deploys a `GnosisSafeProxy` and then passes some data to it. `GnosisSafeProxy` then delegates this data to a `_singleton` address, which in this case is a `GnosisSafe` contract.

The `WalletRegistry` contract makes sure that this data is calling the `setup` function on the `GnosisSafe` contract. The `setup` further delegates a call to an arbitrary address passing along some data. We can exploit this detail to solve the challenge.

We will make the `GnosisSafe` contract delegate a call to a contract that calls the `approve` function on the DVT token contract, approving our solver contract to spend 10 DVT on behalf of the proxy.

Following will be the flow of execution:

```
        deploy                          call                                                  call                          delegate                 delegate                      call
Attacker  ->  SolveBackdoor:constructor  ->   GnosisSafeProxyFactory:createProxyWithCallback   ->  GnosisSafeProxy:fallback   ->     GnosisSafe:setup  ->   Approver:approveTokens  -> DamnValuableToken:approve
                   attacker                              SolveBackdoor                              GnosisSafeProxyFactory        GnosisSafeProxyFactory    GnosisSafeProxyFactory         GnosisSafeProxy
```

Once `SolveBackdoor` gets the allowance, it'll send the tokens to it's `msg.sender` i.e. the attacker.