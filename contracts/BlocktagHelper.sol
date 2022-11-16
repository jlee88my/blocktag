// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;


abstract contract BlocktagHelper
{
    // ==============================
    // EVENTS
    event AddressTagCreated(    address indexed tagger, address itemOfInterest, bytes32 tagId );
    event TransactionTagCreated(address indexed tagger, bytes32 itemOfInterest, bytes32 tagId );
    event AddressTagDeleted(    address indexed tagger, address itemOfInterest, bytes32 tagId );
    event TransactionTagDeleted(address indexed tagger, bytes32 itemOfInterest, bytes32 tagId );


    // ==============================
    // STRUCTURES

    //
    struct AddressTag
    {
        bytes32         tagId;
        uint256         chainId;
        address         tagger;
        address         itemOfInterest;
        string          shortName;
        string          tagDetails;
    }

    //
    struct TransactionTag
    {
        bytes32         tagId;
        uint256         chainId;
        address         tagger;
        bytes32         itemOfInterest;
        string          shortTitle;
        string          tagDetails;
    }

    // Primarily used by app to display a list (with minimal info)
    struct ShortAddressTag
    {
        bytes32         tagId;
        address         itemOfInterest;
        string          shortName;
    }

    // Primarily used by app to display a list (with minimal info)
    struct ShortTransactionTag {
        bytes32         tagId;
        bytes32         itemOfInterest;
        string          shortTitle;
    }



    // =========================================
    // FUNCTIONS
    
    //
    // Generate a unique (and reproducable) byte32 Id from the 3 parameters.
    function generateTagId(address _msgSender, address _address, bytes32 _transactionId)
    virtual public pure returns (bytes32)
    {
        return keccak256(abi.encode(_msgSender, _address, _transactionId));
    }

    //
    // 
    function convertToShortAddressTag( AddressTag memory tag )
    virtual public pure returns (ShortAddressTag memory shortAddressTag)
    {
        return ShortAddressTag(
            {
                tagId:          tag.tagId,
                itemOfInterest: tag.itemOfInterest,
                shortName:      tag.shortName
            }
        );
    }

    //
    //
    function convertToShortTransactionTag( TransactionTag memory tag )
    virtual public pure returns (ShortTransactionTag memory shortTransactionTag)
    {
        return ShortTransactionTag(
            {
                tagId:          tag.tagId,
                itemOfInterest: tag.itemOfInterest,
                shortTitle:     tag.shortTitle
            }
        );
    }

}
