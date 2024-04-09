// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import {DecentralizedStableCoin} from "./DecentralizedStableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
contract DSCEngine is ReentrancyGuard {


    //Errors
    error DSCEngine__NeedsMoreThanZero();
    error DSCEngine__TokenAddressesAndPriceFeedsMustBeSameLength();
    error DSCEngine__NotAllowerToken();
    error DSCEngine__TransferFailed();
    error DSCEngine__BreaksHealthFactor(uint healthFactor);
    error DSCEngine_MintFailed();
    
    //State Variables

    uint private constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint private constant PRECISION = 1e18;
    uint private constant LIQUIDATION_THRESHOLD = 50;
    uint private constant LIQUIDATION_PRECISION = 100;
    uint private constant MIN_HEALTH_FACTOR = 1;
    mapping(address token => address priceFeed) private s_priceFeeds;
    mapping(address user => mapping(address token => uint amt)) private s_collateralDeposited;
    mapping(address user => uint amountDscMinted) private s_DSCMinted;
    address[] private s_collateralTokens;

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
        s_collateralTokens.push(tokenAddresses[i]);
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
     /*
      @notice follows CEI
      @param amountDscToMint the amount of DSC to mint
      @notice they must have more collateral than the minimum threshold
     */
     function mintDsc(uint amountDscToMint) external moreThanZero(amountDscToMint) nonReentrant{
      s_DSCMinted[msg.sender] += amountDscToMint;
      _revertIfHealthFactorIsBroken(msg.sender);
      bool minted = i_dsc.mint(msg.sender,amountDscToMint);
      if(!minted){
        revert DSCEngine_MintFailed();
      }
     }

     function burnDsc() external {}
     function liquidate() external {}
     function getHealthFactor() external view {}
     
     //Private and Internal Function

    function _getAccountInformation(address user) private view returns(uint totalDscMinted,uint collateralValueInUsd){
      totalDscMinted = s_DSCMinted(user);
      collateralValueInUsd = getAccountCollateralValue(user);
    }

     function _healthFactor(address user) private view returns(uint){
      (uint totalDscMinted,uint collateralValueInUsd) = _getAccountInformation(user);
       uint collateralAdjustedForThreshold = (collateralValueInUsd * LIQUIDATION_THRESHOLD) / LIQUIDATION_PRECISION;
       return (collateralAdjustedForThreshold * PRECISION) / totalDSCMinted;
     }

     function _revertIfHealthFactorIsBroken(address user) internal view {
        uint userHealthFactor = _healthFactor(user);
        if(userHealthFactor < MIN_HEALTH_FACTOR){
          revert DSCEngine__BreaksHealthFactor(userHealthFactor);
        }
     }

     //Public & External View Functions
     function getAccountCollateralValue(address user) public view returns(uint totalCollateralValueInUsd){
      for(uint i = 0;i<s_collateralTokens.length;i++){
        address token = s_collateralTokens[i];
        uint amount = s_collateralDeposited[user][token];
        totalCollateralValueInUsd += getUsdValue(token,amount);
      }
      return totalCollateralValueInUsd;
     }

     function getUsdValue(address token,uint amount) public view returns(uint){
      AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeeds[token]);
      uint price = priceFeed.latestRoundData()[1];
      return ((uint(price) * ADDITIONAL_FEED_PRECISION) * amount) / PRECISION;
     }
}