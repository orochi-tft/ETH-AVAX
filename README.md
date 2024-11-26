# Getting Started  

## Executing the Program  
To run this program, use Remix, an online Solidity IDE. Follow these steps:  

### 1. Go to Remix  
Visit the Remix website at [https://remix.ethereum.org](https://remix.ethereum.org).  

### 2. Create a New File  
Click the `+` icon in the left-hand sidebar and save the file with a `.sol` extension (e.g., `LibrarySystem.sol`).  

### 3. Copy and Paste Code  
Copy the following code into the file:  

```solidity
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

    function addBook(uint bookId, string memory title, uint copies) public onlyOwner {
        require(copies > 0, "Number of copies must be greater than zero.");
        books[bookId] = Book(title, copies);
        emit BookAdded(bookId, title, copies);
    }

    function borrowBook(uint bookId, uint quantity) public {
        Book storage book = books[bookId];
        require(bytes(book.title).length > 0, "Book not found.");
        require(quantity > 0, "You must borrow at least one copy.");
        if (quantity > book.copiesAvailable) {
            revert InsufficientCopies({
                available: book.copiesAvailable,
                required: quantity
            });
        }

        book.copiesAvailable -= quantity;
        borrowedBooks[msg.sender][bookId] += quantity;
        emit BookBorrowed(msg.sender, bookId, quantity);
    }

    function returnBook(uint bookId, uint quantity) public {
        uint borrowedQuantity = borrowedBooks[msg.sender][bookId];
        require(quantity > 0, "You must return at least one copy.");
        if (borrowedQuantity < quantity) {
            revert NoBooksBorrowed(bookId);
        }

        borrowedBooks[msg.sender][bookId] -= quantity;
        books[bookId].copiesAvailable += quantity;
        emit BookReturned(msg.sender, bookId, quantity);
    }

    function viewBook(uint bookId) public view returns (string memory title, uint copiesAvailable) {
        Book storage book = books[bookId];
        require(bytes(book.title).length > 0, "Book not found.");
        return (book.title, book.copiesAvailable);
    }

    function withdrawAllFunds() public onlyOwner {
        assert(msg.sender == owner);
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {}
}
```
### 4. Compile the Code
Go to the Solidity Compiler tab.
Ensure the compiler version is set to 0.8.13 (or later).
Click Compile LibrarySystem.sol.

### 5. Deploy the Contract
Go to the Deploy & Run Transactions tab.
Select the Environment (e.g., Remix VM (London)).
Choose the LibrarySystem contract from the dropdown menu.
Click Deploy.

### 6. Interact with the Contract
Use the available functions:

addBook: Add a book to the library.
borrowBook: Borrow books.
returnBook: Return borrowed books.
viewBook: View book details.
Authors
Metacrafter Chris
@metacraftersio

License
This project is licensed under the MIT License - see the LICENSE file for details.
