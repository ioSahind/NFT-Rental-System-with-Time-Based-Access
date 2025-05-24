// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721 {
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

contract NFTRental {
    struct RentalInfo {
        address owner;
        address renter;
        address nftAddress;
        uint256 tokenId;
        uint256 rentalStart;
        uint256 rentalEnd;
        bool isActive;
    }

    uint256 public rentalIdCounter;
    mapping(uint256 => RentalInfo) public rentals;

    event NFTListed(uint256 rentalId, address indexed owner, address nftAddress, uint256 tokenId, uint256 start, uint256 end);
    event NFTRented(uint256 rentalId, address indexed renter, uint256 start, uint256 end);
    event NFTReturned(uint256 rentalId, address indexed owner, address indexed renter);

    function listNFTForRent(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _rentalStart,
        uint256 _rentalEnd
    ) external {
        require(_rentalEnd > _rentalStart, "Invalid rental period");

        rentalIdCounter++;
        rentals[rentalIdCounter] = RentalInfo({
            owner: msg.sender,
            renter: address(0),
            nftAddress: _nftAddress,
            tokenId: _tokenId,
            rentalStart: _rentalStart,
            rentalEnd: _rentalEnd,
            isActive: false
        });

        IERC721(_nftAddress).safeTransferFrom(msg.sender, address(this), _tokenId);
        emit NFTListed(rentalIdCounter, msg.sender, _nftAddress, _tokenId, _rentalStart, _rentalEnd);
    }

    function rentNFT(uint256 _rentalId) external {
        RentalInfo storage rental = rentals[_rentalId];
        require(rental.owner != address(0), "Rental does not exist");
        require(!rental.isActive, "Already rented");
        require(block.timestamp >= rental.rentalStart, "Rental period not started");
        require(block.timestamp < rental.rentalEnd, "Rental period expired");

        rental.renter = msg.sender;
        rental.isActive = true;

        emit NFTRented(_rentalId, msg.sender, rental.rentalStart, rental.rentalEnd);
    }

    function returnNFT(uint256 _rentalId) external {
        RentalInfo storage rental = rentals[_rentalId];
        require(rental.isActive, "Rental not active");
        require(block.timestamp >= rental.rentalEnd, "Rental period not over");
        require(msg.sender == rental.renter, "Only renter can return");

        rental.isActive = false;

        IERC721(rental.nftAddress).safeTransferFrom(address(this), rental.owner, rental.tokenId);
        emit NFTReturned(_rentalId, rental.owner, rental.renter);
    }

    function getRentalDetails(uint256 _rentalId) public view returns (
        address owner,
        address renter,
        address nftAddress,
        uint256 tokenId,
        uint256 rentalStart,
        uint256 rentalEnd,
        bool isActive
    ) {
        RentalInfo memory rental = rentals[_rentalId];
        return (
            rental.owner,
            rental.renter,
            rental.nftAddress,
            rental.tokenId,
            rental.rentalStart,
            rental.rentalEnd,
            rental.isActive
        );
    }
}
