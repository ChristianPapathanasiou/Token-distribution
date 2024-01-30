

from vyper.interfaces import ERC20


event Success:
    amount: uint256

struct DepositEntry:
    beneficiary: address
    amount: uint256

@external 
def distribute(entries: DepositEntry[],erc20_token:address):
    total_amount: uint256 = 0
    for entry in entries:
        total_amount = total_amount + entry.amount 
    
    current_balance: uint256 = ERC20(erc20_token).balanceOf(self)
    ERC20(erc20_token).transferFrom(msg.sender,self,total_amount)
    after_balance: uint256 = ERC20(erc20_token).balanceOf(self)

    assert (after_balance - current_balance) == total_amount, "failed to transfer"

    for entry in entries: 
        beneficiary: address = entry.beneficiary
        beneficiary_amount: uint256 = entry.amount 
        ERC20(erc20_token).transfer(beneficiary,beneficiary_amount)
    

    


