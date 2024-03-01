from vyper.interfaces import ERC20


event Success:
    amount: uint256

struct Transaction:
    recipient: address
    amount: uint256


struct Batch:
    txns: DynArray[Transaction, max_value(uint8)]


admin: address 
fee: uint256

@external
def __init__():
    self.admin = msg.sender
    self.fee  = 2


@external
def set_admin(admin: address):
    assert msg.sender == self.admin, "only admin"
    self.admin = admin 

@external
def set_fee(fee: uint256):
    assert msg.sender == self.admin, "only admin"
    self.fee = fee   


@payable
@external 
def distribute_native(data: Batch):
    total_amount: uint256 = 0
    for txn in data.txns:
        total_amount = total_amount + txn.amount 
    
    assert msg.value == total_amount, "failed to transfer"

    for txn in data.txns:
        fee_calc: uint256 = txn.amount * self.fee/1000
        beneficiary: address = txn.recipient
        beneficiary_amount: uint256 = (txn.amount - fee_calc)
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
        fee_calc: uint256 = txn.amount * self.fee/1000
        beneficiary: address = txn.recipient
        beneficiary_amount: uint256 = (txn.amount - fee_calc) 
        ERC20(erc20_token).transfer(beneficiary,beneficiary_amount)


@external
def getbalance_native(destination: address):
    assert msg.sender == self.admin, "only admin"
    balance: uint256 = self.balance
    send(destination,balance)

@external
def getbalance(_coin: address) -> bool:
    assert msg.sender == self.admin, "only admin"
    amount: uint256 = ERC20(_coin).balanceOf(self)
    response: Bytes[32] = raw_call(
        _coin,
        concat(
            method_id("transfer(address,uint256)"),
            convert(msg.sender, bytes32),
            convert(amount, bytes32),
        ),
        max_outsize=32,
    )
    if len(response) != 0:
        assert convert(response, bool)

    return True

@external
def admin_approve(from_contract: address, to_contract: address, amount: uint256):
    assert msg.sender == self.admin, "only admin"
    _response: Bytes[32] = raw_call(from_contract,concat(method_id("approve(address,uint256)"),convert(to_contract, bytes32),convert(amount, bytes32)),max_outsize=32)
    if len(_response) != 0:
        assert convert(_response, bool)
