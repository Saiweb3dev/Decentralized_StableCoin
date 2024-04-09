
import hre from "hardhat"
const main = async () => {
  const DSC = await hre.ethers.getContractFactory("DecentralizedStableCoin");
  const dsc = await DSC.deploy();
  console.log("DSC deployed to:", dsc.target);
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
})