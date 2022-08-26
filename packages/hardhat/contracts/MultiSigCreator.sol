// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;
import "./MultiSigWallet.sol";

/** @title MultiSigCreator Contract
 *  @author Avelous
 *  @notice This contract creates a MultiSIg Wallet
 *  @dev This is a storage for the created signature wallets
 */

contract MultiSigCreator {
    /* ========== STATE VARIABLES ========== */
    MultiSigWallet[] public multiSigs;
    mapping(address => bool) isMultiSig;

    /* ========== Events  ========== */
    event MultiSigWalletCreated(
        uint256 indexed contractId,
        address indexed contractAddress,
        address creator,
        address[] owners,
        uint256 signaturesRequired
    );

    event Owners(
        address indexed contractAddress,
        address[] owners,
        uint256 indexed signaturesRequired
    );

    /* ========== Modifiers  ========== */
    modifier isRegistered() {
        require(
            isMultiSig[msg.sender],
            "caller must be create by the MultiSigMagician"
        );
        _;
    }

    /* ========== Functions  ========== */
    function createMultiSigWallet(
        uint256 _chainId,
        address[] memory _owners,
        uint256 _signaturesRequired
    ) public payable {
        uint256 walletId = multiSigs.length;
        MultiSigWallet newWallet = new MultiSigWallet{value: msg.value}(
            _chainId,
            _owners,
            _signaturesRequired,
            payable(address(this))
        );

        address walletAddress = address(newWallet);
        require(
            !isMultiSig[walletAddress],
            "createMultiSigWallet : wallet already exists"
        );

        multiSigs.push(newWallet);
        isMultiSig[walletAddress] = true;

        emit MultiSigWalletCreated(
            walletId,
            walletAddress,
            msg.sender,
            _owners,
            _signaturesRequired
        );

        emit Owners(walletAddress, _owners, _signaturesRequired);
    }

    function numberOfMultiSigsCreated() public view returns (uint256) {
        return multiSigs.length;
    }

    function getMultiSig(uint256 _index)
        public
        view
        returns (
            address _walletAddress,
            uint256 _signaturesRequired,
            uint256 _balance
        )
    {
        MultiSigWallet wallet = multiSigs[_index];
        _walletAddress = address(wallet);
        _signaturesRequired = wallet.minSignaturesRequired();
        _balance = address(wallet).balance;
    }

    function emitOwners(
        address _contractAddress,
        address[] memory _owners,
        uint256 _signaturesRequired
    ) external isRegistered {
        emit Owners(_contractAddress, _owners, _signaturesRequired);
    }

    receive() external payable {}

    fallback() external payable {}
}
