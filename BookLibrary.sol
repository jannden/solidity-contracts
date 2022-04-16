// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import "./Ownable.sol";

contract BookLibrary is Ownable {
    struct Book {
        string name;
        uint256 copies;
        uint256 borrowed;
        address[] allBorrowers;
    }
    Book[] books;
    mapping(string => uint256) bookNamesToIds;

    mapping(address => mapping(uint256 => uint256)) borrowerToBookIdsToStatus;
    uint256 constant BORROWED = 1; // This constant may serve as Status in borrowerToBookIdsToStatus
    uint256 constant RETURNED = 2; // This constant may serve as Status in borrowerToBookIdsToStatus

    // This is a struct used to return info about available books
    struct AvailableBook {
        uint256 id;
        string book;
    }

    function _isNewBook(string calldata _name) private view returns (bool) {
        bool newBook = false;
        if (bookNamesToIds[_name] == 0) {
            // If it doesn't exist in a mapping, it has the default value of zero
            newBook = true;
            // But that causes problem when the key really equals to zero, so we need to verify such key by name
            if (books.length > 0) {
                if (
                    keccak256(abi.encodePacked(books[0].name)) ==
                    keccak256(abi.encodePacked(_name))
                ) {
                    newBook = false;
                }
            }
        }
        return newBook;
    }

    function addBook(string calldata _name, uint256 _copies) public onlyOwner {
        require(_copies > 0, "Please add at least one copy.");

        if (_isNewBook(_name)) {
            // If such book doesn't exist yet, we will add it with all info
            Book memory newBook = Book(_name, _copies, 0, new address[](0));
            books.push(newBook);
            bookNamesToIds[_name] = books.length - 1;
        } else {
            // If such book already exists in the libary, we will just increase the number of copies
            books[bookNamesToIds[_name]].copies =
                books[bookNamesToIds[_name]].copies +
                _copies;
        }
    }

    function getAvailableBooks() public view returns (AvailableBook[] memory) {
        // We will first find out the number of available book titles
        // This is due to the fact, that memory arryas have to be fixed-sized
        uint256 counter = 0;
        for (uint256 i = 0; i < books.length; i++) {
            if (books[i].copies - books[i].borrowed > 0) {
                counter++;
            }
        }

        // Then we will fetch the data of the available books
        AvailableBook[] memory availableBooks = new AvailableBook[](counter);
        counter = 0;
        for (uint256 i = 0; i < books.length; i++) {
            if (books[i].copies - books[i].borrowed > 0) {
                availableBooks[counter] = AvailableBook(
                    bookNamesToIds[books[i].name],
                    books[i].name
                );
                counter++;
            }
        }
        return availableBooks;
    }

    function borrowBook(uint256 _id) public bookMustExist(_id) {
        require(
            borrowerToBookIdsToStatus[msg.sender][_id] != BORROWED,
            "Please return the book first."
        );
        require(
            books[_id].copies - books[_id].borrowed > 0,
            "No available copies."
        );

        // Add to allBorrowers if it's the first time user borrows this book
        if (borrowerToBookIdsToStatus[msg.sender][_id] != RETURNED) {
            books[_id].allBorrowers.push(msg.sender);
        }

        // Borrow this book
        borrowerToBookIdsToStatus[msg.sender][_id] = BORROWED;
        books[_id].borrowed = books[_id].borrowed + 1;
    }

    function returnBook(uint256 _id) public bookMustExist(_id) {
        require(
            borrowerToBookIdsToStatus[msg.sender][_id] == BORROWED,
            "You don't currently have this book."
        );
        borrowerToBookIdsToStatus[msg.sender][_id] = RETURNED;
        books[_id].borrowed = books[_id].borrowed - 1;
    }

    function getAllBorrowers(uint256 _id)
        public
        view
        bookMustExist(_id)
        returns (address[] memory)
    {
        return books[_id].allBorrowers;
    }

    modifier bookMustExist(uint256 _id) {
        require(books.length > 0, "No books in the library.");
        require(_id <= books.length - 1, "Book with this ID doesn't exist.");
        _;
    }
}
