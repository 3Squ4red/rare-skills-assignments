# Naive Receiver

Nothing stops someone from issuing flash loans for the `FlashLoanReceiver` contract by calling the `NaiveReceiverLenderPool.flashLoan` function with its address. And each time a flash loan is issued, the `FlashLoanReceiver` contract has to pay 1 ether in fees.

So, in order to drain that contract, issue a flash loan of 0 ether (it could be any value less than 1000) for the receiver contract 10 times (in a loop) within the constructor of a contract and then deploy it.
