const Contract = artifacts.require("WaveDaemons");

module.exports = async function(deployer) {
  await deployer.deploy(Contract);
}

