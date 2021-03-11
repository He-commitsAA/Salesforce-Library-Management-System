@isTest
public with sharing class BookControllerTests {
    @TestSetup
    static void makeData(){
        Branch__c branch = TestDataFactory.createBranch();
        Insert branch;

        User librarian = TestDataFactory.createLibrarian();
        Insert librarian;
        TestDataFactory.setLibrarianBranch(librarian.Id, branch.Id);

        Book__c book = TestDataFactory.createBook();
        Insert book;

        Insert TestDataFactory.createBookCopy(book.Id, branch.Id);

        Insert TestDataFactory.createBorrower();
    }

    @isTest
    public static void checkoutBookTest() {
        User librarian = [SELECT Id FROM User WHERE Name='Test Test'];
        RecordType borrowerRecordType = [SELECT Id FROM RecordType WHERE SobjectType='Contact' AND Name='Borrower'];

        System.runAs(librarian) {
            Contact borrower = [SELECT Id,Name,Card_Number__c FROM Contact WHERE RecordType=:borrowerRecordType.Id];
            Book_Copy__c bookCopy = [SELECT Id,Name,Book__c FROM Book_Copy__c];
            Book_c book = [SELECT Id,Name FROM Book__c WHERE Id=:bookCopy.Book__c];

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
}
