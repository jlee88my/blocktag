const { deployProxy, erc1967 } = require('@openzeppelin/truffle-upgrades');
const art = artifacts.require("Blocktag");

module.exports = async function (deployer, network, accounts)
{
  const instance =  await deployProxy(
                    art
                    , {
                        deployer,
                        initializer: 'initialize',
                      }
                    );
  console.log(':: Deployed Blocktag.')
  console.log('  :: Proxy Addr:', instance.address);

  impAddr        = await erc1967.getImplementationAddress( instance.address);
  console.log('  :: Underlying (Impl) Addr:', impAddr);
};
