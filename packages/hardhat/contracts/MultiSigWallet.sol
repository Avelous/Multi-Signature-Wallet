// SPDX-License-Identifier:MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./MultiSigCreator.sol";

/** @title MultiSigWallet Contract
 *  @author Avelous
 */

contract MultiSigWallet {
    /* ========== Types Declaration ========== */
    using ECDSA for bytes32;

    MultiSigCreator public multiSigCreator;

    /* ========== Events ========== */

    event OwnerChanged(address indexed owner, bool added);
    event Deposit(address indexed sender, uint256 amount, uint256 balance);
    event ExecuteTransaction(
        address indexed owner,
        address indexed to,
        uint256 value,
        bytes data,
        uint256 nonce,
        bytes32 hash,
        bytes result
    );

    /* ========== STATE VARIABLES ========== */
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public minSignaturesRequired;
    uint256 public nonce;
    uint256 chainId;

    /* ========== Modifiers ========== */
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Only Owner and execute");
        _;
    }
    modifier onlySelf() {
        require(msg.sender == address(this), "not self(the contract itself)");
        _;
    }

    modifier atLeastOneSignatures(uint256 _signaturesRequired) {
        require(_signaturesRequired > 0, "at least 1 signatures required");
        _;
    }

    /* ========== Functions ========== */
    constructor(
        uint256 _chainId,
        address[] memory _owners,
        uint256 _signaturesRequired,
        address payable _creatorAddress
    ) payable atLeastOneSignatures(_signaturesRequired) {
        uint256 ownersCount = _owners.length;
        require(ownersCount > 0, "at least 1 owners required");
        require(
            _signaturesRequired <= ownersCount,
            "signatures required can't be greater than owners count"
        );

        for (uint i = 0; i < ownersCount; i++) {
            address owner = _owners[i];
            require(
                address(owner) != address(0),
                "Adress of Owner cannot be zero address"
            );
            require(!isOwner[owner], "Duplicate address not allowed");

            isOwner[owner] = true;
            owners.push(owner);

            emit OwnerChanged(owner, true);
        }

        chainId = _chainId;
        minSignaturesRequired = _signaturesRequired;
        multiSigCreator = MultiSigCreator(_creatorAddress);
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    fallback() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function addOwner(address _owner, uint256 _signaturesRequired)
        public
        onlySelf
        atLeastOneSignatures(_signaturesRequired)
    {
        require(
            address(_owner) != address(0),
            "addOwner : Adress of Owner cannot be zero address"
        );
        require(!isOwner[_owner], "addOwner: Duplicate address not allowed");
        require(
            _signaturesRequired <= owners.length,
            "signatures required cannot be greater than owners count"
        );

        owners.push(_owner);
        minSignaturesRequired = _signaturesRequired;
        isOwner[_owner] = true;
        emit OwnerChanged(_owner, true);
    }

    function removeOwner(address _owner, uint256 _signaturesRerequired)
        public
        onlySelf
        atLeastOneSignatures(_signaturesRerequired)
    {
        require(isOwner[_owner], "removeOwner: not a owner");
        uint256 ownersCount = owners.length;
        require(
            _signaturesRerequired <= ownersCount - 1,
            "removeOwner: signatures required cannot be greater than owners count"
        );
        minSignaturesRequired = _signaturesRerequired;

        delete isOwner[_owner];
        for (uint256 i = 0; i < ownersCount; i++) {
            address owner = owners[i];
            if (owner == _owner) {
                owners[i] = owners[ownersCount - 1];
                owners.pop();
                break;
            }
        }

        emit OwnerChanged(_owner, false);
        multiSigCreator.emitOwners(
            address(this),
            owners,
            _signaturesRerequired
        );
    }

    function updateSignaturesRequired(uint256 _signaturesRequired)
        public
        onlySelf
        atLeastOneSignatures(_signaturesRequired)
    {
        require(
            _signaturesRequired <= owners.length,
            "signatures required cannot be greater than owners count"
        );
        minSignaturesRequired = _signaturesRequired;
    }

    function executeTransaction(
        address payable _receiver,
        uint256 _value,
        bytes calldata _data,
        bytes[] calldata _signatures
    ) public onlyOwner returns (bytes memory) {
        bytes32 _hash = getTransactionHash(nonce, _receiver, _value, _data);

        nonce++;
        uint256 validSignature;
        address duplicateGuard;

        for (uint256 i = 0; i < _signatures.length; i++) {
            bytes memory signature = _signatures[i];
            address recoveredAddress = recover(_hash, signature);

            require(
                duplicateGuard < recoveredAddress,
                "duplicate or unordered signatures"
            );
            duplicateGuard = recoveredAddress;

            if (isOwner[recoveredAddress]) {
                validSignature += 1;
            }
        }

        require(
            validSignature >= minSignaturesRequired,
            "not enough count of signatures"
        );

        (bool success, bytes memory result) = _receiver.call{value: _value}(
            _data
        );
        require(success, "call failed");

        emit ExecuteTransaction(
            msg.sender,
            _receiver,
            _value,
            _data,
            nonce - 1,
            _hash,
            result
        );

        return result;
    }

    function getTransactionHash(
        uint256 _nonce,
        address _receiver,
        uint256 value,
        bytes calldata data
    ) public view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    address(this),
                    chainId,
                    _nonce,
                    _receiver,
                    value,
                    data
                )
            );
    }

    function recover(bytes32 _hash, bytes memory _signature)
        public
        pure
        returns (address)
    {
        return _hash.toEthSignedMessageHash().recover(_signature);
    }
}
