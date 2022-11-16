// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./BlocktagHelper.sol";

contract Blocktag is OwnableUpgradeable, BlocktagHelper
{
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.Bytes32Set;

    // ==============================
    // STATE VARIABLES
    //
    string contractName;

    // Store for all tags
    mapping(bytes32 => BlocktagHelper.AddressTag)           internal    addressTags;
    mapping(bytes32 => BlocktagHelper.TransactionTag)       internal    transactionTags;

    // Tag index by tagger (owner)
    mapping(address => EnumerableSetUpgradeable.Bytes32Set) internal    addressTagIdsByTagger;
    mapping(address => EnumerableSetUpgradeable.Bytes32Set) internal    transactionTagIdsByTagger;



    // ==============================
    // FUNCTIONS

    // Initializations
    constructor() {}
    function initialize() public initializer
    {
        __Ownable_init();
        contractName = "Blocktag v0.1";
    }

    // Note: Tokens (ETH or ERC20) sent to contract address are Donation to me (Thank you)
    receive() external payable virtual {}

    // Note: Any ETH sent to contract address are Donation to me (Thank you)
    function adminWithdrawEther(uint256 _wei)
    virtual external onlyOwner
    {
        payable(_msgSender()).transfer(_wei);
    }

    // Note: Any token sent to contract address are Donation to me (Thank you)
    function adminWithdrawErc20Tokens(address _token) virtual external onlyOwner
    returns (uint256 _qty)
    {
        _qty =   IERC20Upgradeable(_token).balanceOf(address(this));
        if(IERC20Upgradeable(_token).transfer(_msgSender(), _qty))
            {return _qty;}
        return 0;
    }


    // ========================================================
    function addOrEditAddressTag(
        address         itemOfInterest,
        string memory   shortName,
        string memory   tagDetails
    ) virtual external
    returns (BlocktagHelper.AddressTag memory tag)
    {
        tag = BlocktagHelper.AddressTag(
            {
                tagId:              generateTagId(_msgSender(), itemOfInterest, 0x0),
                chainId:            block.chainid,
                tagger:             _msgSender(),
                itemOfInterest:     itemOfInterest,
                shortName:          shortName,
                tagDetails:         tagDetails
            }
        );
        addressTags[tag.tagId] = tag;
        addressTagIdsByTagger[_msgSender()].add(tag.tagId);
        return tag;
    }

    function deleteTransactionTag(
        address         itemOfInterest
    ) virtual external
    returns (bytes32 tagId)
    {
        tagId   = generateTagId(_msgSender(), itemOfInterest, 0x0);
        addressTagIdsByTagger[_msgSender()].remove(tagId);
        delete addressTags[tagId];
        
        return tagId;
    }


    // ========================================================
    function addOrEditTransactionTag(
        bytes32         itemOfInterest,
        string memory   shortTitle,
        string memory   tagDetails
    ) virtual external
    returns (BlocktagHelper.TransactionTag memory tag)
    {
        tag = BlocktagHelper.TransactionTag(
            {
                tagId:              generateTagId(_msgSender(), address(0x0), itemOfInterest),
                chainId:            block.chainid,
                tagger:             _msgSender(),
                itemOfInterest:     itemOfInterest,
                shortTitle:         shortTitle,
                tagDetails:         tagDetails
            }
        );
        transactionTags[tag.tagId] = tag;
        transactionTagIdsByTagger[_msgSender()].add(tag.tagId);
        return tag;
    }

    function deleteAddressTag(
        address         itemOfInterest
    ) virtual external
    returns (bytes32 tagId)
    {
        tagId   = generateTagId(_msgSender(), itemOfInterest, 0x0);
        addressTagIdsByTagger[_msgSender()].remove(tagId);
        delete addressTags[tagId];
        
        return tagId;
    }


    // ========================================================
    function getAddressTagDetail( address itemOfInterest )
    virtual external
    returns (BlocktagHelper.AddressTag memory tag)
    {
        bytes32 tagId   = generateTagId(_msgSender(), itemOfInterest, 0x0);
        return addressTags[tagId];
    }

    function getTransactionTagDetail( bytes32 itemOfInterest )
    virtual external
    returns (BlocktagHelper.TransactionTag memory tag)
    {
        bytes32 tagId   = generateTagId(_msgSender(), address(0x0), itemOfInterest);
        return transactionTags[tagId];
    }

    function getAddressTagDetailList( address tagger )
    virtual public
    returns (BlocktagHelper.AddressTag[] memory)
    {
        bytes32[] memory tagIds = addressTagIdsByTagger[tagger].values();
        uint256 tagCount        = addressTagIdsByTagger[tagger].length();
        BlocktagHelper.AddressTag[] memory
            tags                = new BlocktagHelper.AddressTag[](tagCount);

        for(uint256 n = (tagCount-1); n >= 0; n--)
        {
            tags[n] = addressTags[tagIds[n]];
        }
        return tags;
    }

    function getTransactionTagDetailList( address tagger )
    virtual public
    returns (BlocktagHelper.TransactionTag[] memory)
    {
        bytes32[] memory tagIds = transactionTagIdsByTagger[tagger].values();
        uint256 tagCount        = transactionTagIdsByTagger[tagger].length();
        BlocktagHelper.TransactionTag[] memory
            tags                = new BlocktagHelper.TransactionTag[](tagCount);

        for(uint256 n = (tagCount-1); n >= 0; n--)
        {
            tags[n] = transactionTags[tagIds[n]];
        }
        return tags;
    }

    function getShortAddressTagList( address tagger )
    virtual external
    returns (BlocktagHelper.ShortAddressTag[] memory)
    {
        BlocktagHelper.AddressTag[] memory
            detailedTags    = getAddressTagDetailList( tagger );
        uint256 tagCount    = detailedTags.length;

        BlocktagHelper.ShortAddressTag[] memory
            tags            = new BlocktagHelper.ShortAddressTag[](tagCount);
        for(uint256 n = 0; n < tagCount; n++ )
        {
            tags[n] = convertToShortAddressTag(detailedTags[n]);
        }
        return tags;
    }

    function getShortTransactionTagList( address tagger )
    virtual external
    returns (BlocktagHelper.ShortTransactionTag[] memory)
    {
        BlocktagHelper.TransactionTag[] memory
            detailedTags    = getTransactionTagDetailList( tagger );
        uint256 tagCount    = detailedTags.length;

        BlocktagHelper.ShortTransactionTag[] memory
            tags            = new BlocktagHelper.ShortTransactionTag[](tagCount);
        for(uint256 n = 0; n < tagCount; n++ )
        {
            tags[n] = convertToShortTransactionTag(detailedTags[n]);
        }
        return tags;
    }

}
