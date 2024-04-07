// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import {DecentralizedStableCoin} from "./DecentralizedStableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
contract DSCEngine is ReentrancyGuard {


    //Errors
    error DSCEngine__NeedsMoreThanZero();
    error DSCEngine__TokenAddressesAndPriceFeedsMustBeSameLength();
    error DSCEngine__NotAllowerToken();
    error DSCEngine__TransferFailed()
    
    //State Variables
    mapping(address token => address priceFeed) private s_priceFeeds;
    mapping(address user => mapping(address token => uint amt)) private s_collateralDeposited;

    DecentralizedStableCoin private immutable i_dsc;
    
    //Events
    event CollateralDeposited(address indexed user, address indexed token, uint indexed amount);



    // Modifiers
    modifier moreThanZero(uint amt){
      if(amt == 0){
        revert DSCEngine__NeedsMoreThanZero();
      }
      _;
    }

    modifier isAllowedToken(address token){
      if(token == address(0)){
        revert DSCEngine__NotAllowerToken();
      }
      _;
    }
    //Functions
    constructor(address[] memory tokenAddresses,address[] memory priceFeedAddresses,address dscAddress) {
      if(tokenAddresses.length != priceFeedAddresses.length){
        revert DSCEngine__TokenAddressesAndPriceFeedsMustBeSameLength();
      }
      for(uint i=0;i<tokenAddresses.length;i++){
        s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
      }
      i_dsc = DecentralizedStableCoin(dscAddress);
    }

    //External Functions
     function depositCollateralAndMintDsc() external {
      
     }
     /*
     *@param tokenCollateralAddress the address of the collateral token
     *@param amountCollateral the amount of collateral
     */
     function depositCollateral(address tokenCollateralAddress,uint amountCollateral) external moreThanZero(amountCollateral) isAllowedToken(tokenCollateralAddress) nonReentrant {
       s_collateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral;
       emit CollateralDeposited(msg.sender,tokenCollateralAddress,amountCollateral);
       bool success =IERC20(tokenCollateralAddress).safeTransferFrom(msg.sender,address(this),amountCollateral);
       if(!success){
         revert DSCEngine__TransferFailed();
       }
     }
     function redeemCollateralForDsc() external {

     }
     function redeemCollateral() external {

     }
     function mintDsc() external {}
     function burnDsc() external {}
     function liquidate() external {}
     function getHealthFactor external view {}
}