@isTest
public with sharing class BookControllerTests {
    @TestSetup
    static void makeData(){
        Branch__c branch = TestDataFactory.createBranch();
        Insert branch;

        User librarian = TestDataFactory.createLibrarian();
        Test.startTest();
        Insert librarian;
        Test.stopTest();
        TestDataFactory.setLibrarianBranch(librarian.Id, branch.Id);

        Book__c book = TestDataFactory.createBook();
        Insert book;

        Insert TestDataFactory.createBookCopy(book.Id, branch.Id);

        Insert TestDataFactory.createBorrower();
    }

    @isTest
    public static void checkoutBookTest() {
        User librarian = [SELECT Id FROM User WHERE Name='Test Test'];
        
        System.runAs(librarian) {
            RecordType borrowerRecordType = [SELECT Id FROM RecordType WHERE SobjectType='Contact' AND Name='Borrower'];
            Contact borrower = [SELECT Id,Name,Card_Number__c FROM Contact WHERE RecordTypeId=:borrowerRecordType.Id];
            Book_Copy__c bookCopy = [SELECT Id,Name,Book__c FROM Book_Copy__c];
            Book__c book = [SELECT Id,Name FROM Book__c WHERE Id=:bookCopy.Book__c];

            String result = BookController.checkoutBook(bookCopy.Name, borrower.Card_Number__c);
            System.assertEquals('Checked out copy of ' + book.Name + ' to ' + borrower.Name, result);

            Loan__c loan = [SELECT Borrower__c,Checkout__c,Due__c FROM Loan__c WHERE Book_Copy__c=:bookCopy.Id];
            System.assertEquals(borrower.Id, loan.Borrower__c);
            System.assertEquals(Date.today(), loan.Checkout__c);
            System.assertEquals(Date.today().addDays(14), loan.Due__c);

            bookCopy = [SELECT Book__c,Borrower__c,Branch__c,Condition__c FROM Book_Copy__c WHERE Id=:bookCopy.Id];
            System.assertEquals(book.Id, bookCopy.Book__c);
            System.assertEquals(borrower.Id, bookCopy.Borrower__c);
            System.assertEquals(null, bookCopy.Branch__c);
            System.assertEquals('Used', bookCopy.Condition__c);
        }
    }

    @isTest
    public static void checkoutBookInvalidBookErrorTest() {
        User librarian = [SELECT Id FROM User WHERE Name='Test Test'];
        
        System.runAs(librarian) {
            RecordType borrowerRecordType = [SELECT Id FROM RecordType WHERE SobjectType='Contact' AND Name='Borrower'];
            Contact borrower = [SELECT Card_Number__c FROM Contact WHERE RecordTypeId=:borrowerRecordType.Id];

            Boolean gotError = false;
            try {
                BookController.checkoutBook('', borrower.Card_Number__c);
            } catch (InputException e) {
                gotError = true;
                System.assertEquals('Invalid Book Serial Number', e.getMessage());
            }

            System.assert(gotError);
        }
    }

    @isTest
    public static void checkoutBookInvalidBorrowerErrorTest() {
        User librarian = [SELECT Id FROM User WHERE Name='Test Test'];
        
        System.runAs(librarian) {
            Book_Copy__c bookCopy = [SELECT Name FROM Book_Copy__c];

            Boolean gotError = false;
            try {
                BookController.checkoutBook(bookCopy.Name, '');
            } catch (InputException e) {
                gotError = true;
                System.assertEquals('Invalid Card Number', e.getMessage());
            }

            System.assert(gotError);
        }
    }

    @isTest
    public static void checkoutBookCheckedOutErrorTest() {
        User librarian = [SELECT Id FROM User WHERE Name='Test Test'];
        
        System.runAs(librarian) {
            RecordType borrowerRecordType = [SELECT Id FROM RecordType WHERE SobjectType='Contact' AND Name='Borrower'];
            Contact borrower = [SELECT Card_Number__c FROM Contact WHERE RecordTypeId=:borrowerRecordType.Id];
            Book_Copy__c bookCopy = [SELECT Name FROM Book_Copy__c];

            BookController.checkoutBook(bookCopy.Name, borrower.Card_Number__c);

            Boolean gotError = false;
            try {
                BookController.checkoutBook(bookCopy.Name, borrower.Card_Number__c);
            } catch (InputException e) {
                gotError = true;
                System.assertEquals('Book is already checked out', e.getMessage());
            }

            System.assert(gotError);
        }
    }
}
