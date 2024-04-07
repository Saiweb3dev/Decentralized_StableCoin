// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ERC20Burnable,ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract DecentralizedStableCoin is ERC20Burnable, Ownable {

   error DSC__MustBeMoreThanZero();
   error DSC__BurnAmountExceedsBalance();
   error DSC__NotZeroAddress();

    constructor() ERC20("DecentralizedStableCoin","DSC") {

    }

    function burn(uint _amt) public override onlyOwner{
        uint balance = balanceOf(msg.sender);
        if(_amt <= 0){
            revert DSC__MustBeMoreThanZero();
        }
        if(balance < _amt){
            revert DSC__BurnAmountExceedsBalance();
        }
        super.burn(_amt);
    }

    function mint(address _to,uint _amt) external onlyOwner returns(bool){
      if(_to == address(0)){
        revert DSC__NotZeroAddress();
      }
      if(_amt <= 0){
        revert DSC__MustBeMoreThanZero();
      }
      _mint(_to,_amt);
      return true;
    }
}