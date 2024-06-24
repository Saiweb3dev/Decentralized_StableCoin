import { ethers } from "hardhat";

export interface networkConfigItem {
   name?: string
   subscriptionId?: string 
   gasLane?: string 
   keepersUpdateInterval?: string 
   raffleEntranceFee?: string 
   callbackGasLimit?: string 
   vrfCoordinatorV2?: string
 }
export interface networkConfigInfo{
   [key:number]:networkConfigItem
}

export const networkConfig: networkConfigInfo ={
   
}