// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract Allowance is Ownable {
    using SafeMath for uint;
    event AllowanceChanged(address indexed forwho, address fromwhome, uint oldAmount, uint newAmount);
 mapping (address => uint) public allowance;
 function isOwner() public view returns(bool) {
    if(owner() == msg.sender){
     return true;
     }
 }

 function addAllowance(address allow , uint amount) public onlyOwner{
     emit AllowanceChanged(allow, msg.sender, allowance[allow], amount);
            allowance[allow] = amount;
 }
 
 modifier ownerOrAllowance(uint _amount) {
     require( isOwner() || allowance[msg.sender] >= _amount, "you are not Allowed");
     _;
 }
 function reduceAllowance(address who, uint amount) internal {
     emit AllowanceChanged(who, msg.sender, allowance[who], allowance[who].sub(amount));
            allowance[who] =allowance[who].sub(amount);

 }

}

contract Wallet is Allowance { 
 /*   address owner;

    constructor() public{
        owner = msg.sender;
    }
    modifier onlyOwner(){
        require(msg.sender == owner, "you are not owner");
        _;
    }
*/
    event MoneySent(address indexed beneficiary, uint amount);
    event MoneyReceived(address indexed from, uint amount);

  function withdrawMoney(address payable to, uint _amount) public ownerOrAllowance(_amount){
      require (_amount <= address(this).balance, "there are not enough funds in smart contract");
      if(!isOwner()) {
          reduceAllowance(msg.sender, _amount);
      }
      emit MoneySent(to, _amount);
    to.transfer(_amount);

  }
  function renounceOwnership() public override virtual onlyOwner {
      revert(" Can not Renounce ownership");
  }
    fallback() external payable {
        emit MoneyReceived(msg.sender, msg.value);

    }
}