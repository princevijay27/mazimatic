// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NFTMinting is ERC721Enumerable, ReentrancyGuard {
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private tokenID;

    struct USER {
        bool status;
        uint256 _quantity;
    }

    address public owner;
    bool public paused;

    string public baseURI;
    string public baseExtension = ".json";

    mapping(address => USER) userInfo;
    mapping(address => uint256[]) userTokenId;

    modifier onlyOwner() {
        require(owner == msg.sender, "not owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Minting paused");
        _;
    }

    event UpdateOwner(address oldOwner, address newOwner);
    event MINT(address user, uint256 mintAmount);

    constructor(
        address _owner,
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI
    ) ERC721(_name, _symbol) {
        owner = _owner;
        baseURI = _initBaseURI;
    }

    function setOwner(address _owner) external nonReentrant onlyOwner {
        owner = _owner;
        emit UpdateOwner(msg.sender, owner);
    }

    function setBaseURI(string memory _newBaseURI)
        external
        nonReentrant
        onlyOwner
    {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension)
        external
        nonReentrant
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    function withdrawCoin(uint256 _amount) external nonReentrant onlyOwner {
        coinTransaction(owner, _amount);
    }

    function addUserDetails(address user, uint256 _quantity)
        external
        nonReentrant
        onlyOwner
    {
        uint256 quantity = userInfo[user]._quantity + _quantity;
        userInfo[user] = USER(true, quantity);
    }

    function mint(uint256 _mintAmount) external nonReentrant whenNotPaused {
        require(!paused, "contract paused");
        require(_mintAmount > 0, "not null");
        require(userInfo[msg.sender].status, "user not whitelist");
        require(
            _mintAmount <= userInfo[msg.sender]._quantity,
            "above max quantity"
        );

        for (uint256 i = 1; i <= _mintAmount; i++) {
            tokenID.increment();
            _safeMint(msg.sender, tokenID.current());
            userTokenId[msg.sender].push(tokenID.current());
        }

        userInfo[msg.sender]._quantity =
            userInfo[msg.sender]._quantity -
            _mintAmount;

        emit MINT(msg.sender, _mintAmount);
    }

    function getTokenId(address _to) external view returns (uint256[] memory) {
        return userTokenId[_to];
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        "/",
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }

    function coinTransaction(address _to, uint256 _amount) internal {
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "refund failed");
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }
}
