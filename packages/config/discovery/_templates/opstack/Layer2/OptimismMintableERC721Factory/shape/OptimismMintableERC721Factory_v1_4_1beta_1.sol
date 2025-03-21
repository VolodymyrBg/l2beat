// SPDX-License-Identifier: Unknown
pragma solidity 0.8.15;

interface ISemver {
    /// @notice Getter for the semantic version of the contract. This is not
    ///         meant to be used onchain but instead meant to be used by offchain
    ///         tooling.
    /// @return Semver contract version as a string.
    function version() external view returns (string memory);
}

contract OptimismMintableERC721Factory is ISemver {
    /// @notice Address of the ERC721 bridge on this network.
    address public immutable BRIDGE;

    /// @notice Chain ID for the remote network.
    uint256 public immutable REMOTE_CHAIN_ID;

    /// @notice Tracks addresses created by this factory.
    mapping(address => bool) public isOptimismMintableERC721;

    /// @notice Emitted whenever a new OptimismMintableERC721 contract is created.
    /// @param localToken  Address of the token on the this domain.
    /// @param remoteToken Address of the token on the remote domain.
    /// @param deployer    Address of the initiator of the deployment
    event OptimismMintableERC721Created(address indexed localToken, address indexed remoteToken, address deployer);

    /// @notice Semantic version.
    /// @custom:semver 1.4.1-beta.1
    string public constant version = "1.4.1-beta.1";

    /// @notice The semver MUST be bumped any time that there is a change in
    ///         the OptimismMintableERC721 token contract since this contract
    ///         is responsible for deploying OptimismMintableERC721 contracts.
    /// @param _bridge Address of the ERC721 bridge on this network.
    /// @param _remoteChainId Chain ID for the remote network.
    constructor(address _bridge, uint256 _remoteChainId) {
        BRIDGE = _bridge;
        REMOTE_CHAIN_ID = _remoteChainId;
    }

    /// @notice Creates an instance of the standard ERC721.
    /// @param _remoteToken Address of the corresponding token on the other domain.
    /// @param _name        ERC721 name.
    /// @param _symbol      ERC721 symbol.
    function createOptimismMintableERC721(
        address _remoteToken,
        string memory _name,
        string memory _symbol
    )
        external
        returns (address)
    {
        require(_remoteToken != address(0), "OptimismMintableERC721Factory: L1 token address cannot be address(0)");

        bytes32 salt = keccak256(abi.encode(_remoteToken, _name, _symbol));
        address localToken =
            address(new OptimismMintableERC721{ salt: salt }(BRIDGE, REMOTE_CHAIN_ID, _remoteToken, _name, _symbol));

        isOptimismMintableERC721[localToken] = true;
        emit OptimismMintableERC721Created(localToken, _remoteToken, msg.sender);

        return localToken;
    }
}