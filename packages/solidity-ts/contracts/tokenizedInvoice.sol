// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@solvprotocol/erc-3525/ERC3525.sol";

contract TokenizedInvoice is ERC3525 {
  using Strings for uint256;
  address public owner;

  constructor() ERC3525("TokenizedInvoice", "Inv", 18) {}

  function mint(uint256 slot_, uint256 amount_) external {
    _mint(msg.sender, slot_, amount_); // mint to invoiceFinancing contract
  }
}
