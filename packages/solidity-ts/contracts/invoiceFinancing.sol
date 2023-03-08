pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./tokenizedInvoice.sol";

//import "@openzeppelin/contracts/access/Ownable.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract InvoiceFinancing {
  TokenizedInvoice public tokenizedInvoice; // TODO public or private

  constructor() {
    // 🙋🏽‍♂️ what should we do on deploy?
    tokenizedInvoice = new TokenizedInvoice();
  }

  struct Seller {
    bytes32 name;
    address accountAddress;
  }

  struct Buyer {
    bytes32 name;
    address accountAddress;
  }

  struct Transporter {
    bytes32 name;
    address accountAddress;
  }

  struct Invoice {
    bytes32 nameFrom;
    bytes32 nameTo;
    uint256 value;
    uint256 expiration_date;
    address from;
    address to;
    bool paidFrom;
    bool paidTo;
  }

  struct PO {
    bytes32 nameFrom;
    bytes32 nameTo;
    uint256 value;
    uint256 expiration_date;
    address from;
    address to;
    bool paidFrom;
    bool paidTo;
  }

  mapping(address => Seller) public sellers;
  mapping(address => Buyer) public buyers;
  // map address to a list of invoices
  mapping(address => Invoice[]) public invoices; // FUTURE TODO: multiple invoices from one seller to one buyer
  mapping(address => PO[]) public pos;
  mapping(address => bool) public invoiceMatchPo;

  /* 
  assuming seller and transporter have settled the PO. 
  In original paper, accepting invoice is part of the invoice financing
  However, invoice financing and invoice accept and shipment could be separated, 
  decoupling them make invoice financing integration with non blockchain solution easier 
   */

  // apply to be a seller
  function applySeller(bytes32 name, address accountAddress) public {
    sellers[accountAddress] = Seller(name, accountAddress); // TODO seller func need to check if seller exist
  }

  // apply to be a buyer
  function applyBuyer(bytes32 name, address accountAddress) public {
    buyers[accountAddress] = Buyer(name, accountAddress); // TODO buyer func need to check if seller exist
  }

  // Seller input invoice
  function inputInvoice(
    bytes32 nameFrom,
    bytes32 nameTo,
    uint256 value,
    uint256 expiration_date,
    address from,
    address to
  ) public {
    invoices[from] = Invoice(nameFrom, nameTo, value, expiration_date, from, to, false, false);
    // FUTURE TODO modify it into taking huge amount of data, if applicable, else just use the one above
  }

  // Seller input PO
  function inputPO(
    bytes32 nameFrom,
    bytes32 nameTo,
    uint256 value,
    uint256 expiration_date,
    address from,
    address to
  ) public {
    pos[from] = PO(nameFrom, nameTo, value, expiration_date, from, to, false, false);
    require(pos[from].paidFrom == true, "PO is not paid from");
    require(pos[from].paidTo == true, "PO is not paid to");
    // TODO PO exist and paid, fail when not exist, ask seller and transporter to input PO
  }

  // Seller ask transporter to input PO
  function inputPOFromTransporter(
    bytes32 nameFrom,
    bytes32 nameTo,
    uint256 value,
    uint256 expiration_date,
    address from,
    address to
  ) public {
    pos[from] = PO(nameFrom, nameTo, value, expiration_date, from, to, false, false);
  }

  event InvoiceAccepted(address from, address to);

  // validate invoice with PO
  function validateInvoice(address from, address to) public {
    require(invoices[from].value == pos[to].value, "Invoice value is not equal to PO value");
    require(invoices[from].expiration_date == pos[to].expiration_date, "Invoice expiration date is not equal to PO expiration date");
    require(invoices[from].nameFrom == pos[to].nameFrom, "Invoice nameFrom is not equal to PO nameFrom");
    require(invoices[from].nameTo == pos[to].nameTo, "Invoice nameTo is not equal to PO nameTo");
    // invoice accepted
    emit InvoiceAccepted(from, to);
  }

  // tokenize invoice
  function tokenizeInvoice(address from, address to) public {
    require(sellers[msg.sender].accountAddress == msg.sender, "Caller is not a seller");
    // if invoice
    tokenizedInvoice.mint(invoices[from].value, 100);
  }

  // investor function: buy tokenized invoice, only limited buyer can view
  // pool of tokenized invoice
  function buyTokenizedInvoice(
    address from,
    address to,
    uint256 amount
  ) public {
    require(buyers[msg.sender].accountAddress == msg.sender, "Caller is not a buyer");
    pricing();
    tokenizedInvoice.transferFrom(from, to, amount);
  }

  // pricing based on seller credit score
  function pricing(address from, address to) public {
    // automatic pricing and manual pricing and assurance company together
    // TODO: decide which
    // issue at discount
    // assurance company
  }
  // future TODO: appropriate periodically payment, once risk is low enough
  // intentionally default: credit score drop,
}

/* 
Account receivable financing：seller 給 financier 一張 invoice, financier 買下 invoice, financier 跟 buyer 收錢
(V) invoice financing: seller 給 financier 一張 invoice, financier 沒有買下 invoice, financier 跟 seller 收錢
*/

/* 
Future TODO:

datatable 
1 $  
2 $ 
3 $ 
4 $ 
=>
zkp circuit
=>
zkp proof：
*/
