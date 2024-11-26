// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract LibrarySystem {
    struct Book {
        string title;
        uint copiesAvailable;
    }

    address public owner;
    mapping(uint => Book) public books; // Book ID to Book details
    mapping(address => mapping(uint => uint)) public borrowedBooks; // User to Book ID to quantity

    event BookAdded(uint bookId, string title, uint copies);
    event BookBorrowed(address indexed user, uint bookId, uint quantity);
    event BookReturned(address indexed user, uint bookId, uint quantity);

    error InsufficientCopies(uint available, uint required);
    error NoBooksBorrowed(uint bookId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Add new books to the library
    function addBook(uint bookId, string memory title, uint copies) public onlyOwner {
        require(copies > 0, "Number of copies must be greater than zero.");
        books[bookId] = Book(title, copies);
        emit BookAdded(bookId, title, copies);
    }

    // Borrow a book from the library
    function borrowBook(uint bookId, uint quantity) public {
        Book storage book = books[bookId];

        // Ensure the book exists and there are enough copies to borrow
        require(bytes(book.title).length > 0, "Book not found.");
        require(quantity > 0, "You must borrow at least one copy.");
        if (quantity > book.copiesAvailable) {
            revert InsufficientCopies({
                available: book.copiesAvailable,
                required: quantity
            });
        }

        // Update records
        book.copiesAvailable -= quantity;
        borrowedBooks[msg.sender][bookId] += quantity;

        emit BookBorrowed(msg.sender, bookId, quantity);
    }

    // Return a borrowed book to the library
    function returnBook(uint bookId, uint quantity) public {
        uint borrowedQuantity = borrowedBooks[msg.sender][bookId];
        require(quantity > 0, "You must return at least one copy.");
        if (borrowedQuantity < quantity) {
            revert NoBooksBorrowed(bookId);
        }

        // Update records
        borrowedBooks[msg.sender][bookId] -= quantity;
        books[bookId].copiesAvailable += quantity;

        emit BookReturned(msg.sender, bookId, quantity);
    }

    // View the details of a book
    function viewBook(uint bookId) public view returns (string memory title, uint copiesAvailable) {
        Book storage book = books[bookId];
        require(bytes(book.title).length > 0, "Book not found.");
        return (book.title, book.copiesAvailable);
    }

    // Withdraw all Ether in the contract (if any), restricted to the owner
    function withdrawAllFunds() public onlyOwner {
        assert(msg.sender == owner); // Ensure invariant
        payable(owner).transfer(address(this).balance);
    }

    // Receive function for accepting Ether donations (optional)
    receive() external payable {}
}
