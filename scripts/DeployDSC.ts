
import hre from "hardhat"
const main = async () => {
  const DSC = await hre.ethers.getContractFactory("DecentralizedStableCoin");
  const DSCEngine = await hre.ethers.getContractFactory("DSCEngine");
  const dsc = await DSC.deploy();
  const dscEngine = await DSCEngine.deploy
  console.log("DSC deployed to:", dsc.target);
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
})