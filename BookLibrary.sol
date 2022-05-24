// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Ownable.sol";

contract BookLibrary is Ownable {
    struct Book {
        string name;
        uint256 copies;
        address[] borrowers;
    }
    Book[] private books;

    // This is a struct used to return info about available books
    struct AvailableBook {
        uint256 id;
        string name;
    }

    // Events
    event NewBookAdded(uint256 id, string name);
    event NewCopiesAdded(uint256 id, uint256 copies);
    event BookBorrowed(uint256 indexed id, address borrower);
    event BookReturned(uint256 id, address borrower);

    function addBook(string calldata _name, uint256 _copies) public onlyOwner {
        require(_copies > 0, "Please add at least one copy.");

        for (uint256 i = 0; i < books.length; i++) {
            if (
                keccak256(abi.encodePacked(books[i].name)) ==
                keccak256(abi.encodePacked(_name))
            ) {
                // If such book already exists in the libary, we will just increase the number of copies
                books[i].copies = books[i].copies + _copies;
                emit NewCopiesAdded(i, _copies);
                return;
            }
        }

        // If such book doesn't exist yet, we will add it with all info
        books.push();
        books[books.length - 1].name = _name;
        books[books.length - 1].copies = _copies;
        emit NewBookAdded(books.length - 1, _name);
    }

    function getAvailableBooks() public view returns (AvailableBook[] memory) {
        // We will first find out the number of available book titles
        // This is due to the fact, that memory arrays have to be fixed-sized
        uint256 counter = 0;
        for (uint256 i = 0; i < books.length; i++) {
            if (books[i].copies - books[i].borrowers.length > 0) {
                counter++;
            }
        }

        // Then we will fetch the data of the available books
        AvailableBook[] memory availableBooks = new AvailableBook[](counter);
        counter = 0;
        for (uint256 i = 0; i < books.length; i++) {
            if (books[i].copies - books[i].borrowers.length > 0) {
                availableBooks[counter] = AvailableBook(i, books[i].name);
                counter++;
            }
        }
        return availableBooks;
    }

    function _hasBook(uint256 _id, address _user) private view returns (bool) {
        for (uint256 i = 0; i < books[_id].borrowers.length; i++) {
            if (_user == books[_id].borrowers[i]) {
                return true;
            }
        }
        return false;
    }

    function borrowBook(uint256 _id) public bookMustExist(_id) {
        require(
            _hasBook(_id, msg.sender) == false,
            "Please return the book first."
        );

        require(
            books[_id].copies - books[_id].borrowers.length > 0,
            "No available copies."
        );

        // Borrow this book
        books[_id].borrowers.push(msg.sender);
        emit BookBorrowed(_id, msg.sender);
    }

    function returnBook(uint256 _id) public bookMustExist(_id) {
        require(
            _hasBook(_id, msg.sender) == true,
            "Sender doesn't have this book."
        );
        for (uint256 i = 0; i < books[_id].borrowers.length; i++) {
            if (msg.sender == books[_id].borrowers[i]) {
                _removeIndexFromAddressArray(books[_id].borrowers, i);
                emit BookReturned(_id, msg.sender);
                return;
            }
        }
    }

    function _removeIndexFromAddressArray(
        address[] storage _array,
        uint256 _index
    ) private {
        _array[_index] = _array[_array.length - 1];
        _array.pop();
    }

    modifier bookMustExist(uint256 _id) {
        require(books.length > 0, "No books in the library.");
        require(_id <= books.length - 1, "Book with this ID doesn't exist.");
        _;
    }
}
