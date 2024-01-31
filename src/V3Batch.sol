pragma solidity ^0.8.17;

import "@aave/core-v3/contracts/flashloan/interfaces/IFlashLoanSimpleReceiver.sol";
import "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import "@aave/core-v3/contracts/interfaces/IPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AaveFlashloan is IFlashLoanSimpleReceiver {
    IERC20 public token;
    IPoolAddressesProvider public immutable i_AddressProvider;
    IPool public immutable i_pool;

    bool flag = false;

    // AddressProviderAddress for Goerli V3 = 0xc4dCB5126a3AfEd129BC3668Ea19285A9f56D15D
    // Check out docs.aave at https://docs.aave.com/developers/deployed-contracts/v3-testnet-addresses
    // for your respective testnet

    constructor(address AddressProviderAddress) {
        i_AddressProvider = IPoolAddressesProvider(AddressProviderAddress);
        i_pool = IPool(i_AddressProvider.getPool());
    }

    // DAI StableCoin for Goerli 0xDF1742fE5b0bFc12331D8EAec6b478DfDbD31464
    function setToken(address tokenAddress) public {
        token = IERC20(tokenAddress);
    }

    function AddTokensForPremium(uint256 amount) public {
        token.transfer(address(this), amount);
    }

    function TokensInContract() public view {
        token.balanceOf(address(this));
    }

    function FlashloanPremiumFees() public view returns (uint256) {
        return i_pool.FLASHLOAN_PREMIUM_TOTAL();
    }

    function flashloan(uint256 amount) public {
        i_pool.flashLoanSimple(address(this), address(token), amount, "0x", 0);
    }

    function ADDRESSES_PROVIDER() public view returns (IPoolAddressesProvider) {
        return i_AddressProvider;
    }

    function POOL() public view returns (IPool) {
        return i_pool;
    }

    function executeOperation(
        address,
        uint256 amount,
        uint256 premium,
        address,
        bytes calldata
    ) external returns (bool) {
        uint256 amountToReturn = amount + premium;
        token.approve(address(i_pool), amountToReturn);
        flag = true;
        return flag;
    }

    function resetFlag() public {
        flag = false;
    }
}