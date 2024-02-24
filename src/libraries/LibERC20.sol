// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";
import { ERC20Address } from "codegen/index.sol";

library LibERC20 {
    using SafeERC20 for IERC20;

    function collect(address from, uint256 value) internal {
        IERC20 token = IERC20(ERC20Address.get());
        token.safeTransferFrom(from, address(this), value);
    }

    function transferTo(address to, uint256 value) internal {
        IERC20 token = IERC20(ERC20Address.get());
        token.safeTransfer(to, value);
    }
}
