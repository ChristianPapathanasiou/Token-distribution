from vyper.interfaces import ERC20


event Success:
    amount: uint256

struct Transaction:
    recipient: address
    amount: uint256


struct Batch:
    txns: DynArray[Transaction, max_value(uint8)]

@payable
@external 
def distribute_native(data: Batch):
    total_amount: uint256 = 0
    for txn in data.txns:
        total_amount = total_amount + txn.amount 
    
    assert msg.value == total_amount, "failed to transfer"

    for txn in data.txns: 
        beneficiary: address = txn.recipient
        beneficiary_amount: uint256 = txn.amount 
        send(beneficiary,beneficiary_amount)

@external 
def distribute(data: Batch,erc20_token:address):
    total_amount: uint256 = 0
    for txn in data.txns:
        total_amount = total_amount + txn.amount 
    
    current_balance: uint256 = ERC20(erc20_token).balanceOf(self)
    ERC20(erc20_token).transferFrom(msg.sender,self,total_amount)
    after_balance: uint256 = ERC20(erc20_token).balanceOf(self)

    assert (after_balance - current_balance) == total_amount, "failed to transfer"

    for txn in data.txns: 
        beneficiary: address = txn.recipient
        beneficiary_amount: uint256 = txn.amount 
        ERC20(erc20_token).transfer(beneficiary,beneficiary_amount)
