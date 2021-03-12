public with sharing class BookController {
    @AuraEnabled(cacheable=true)
    public static List<Book__c> getBookList() {
        return [select id,Name,Author__c from Book__c];
    }

    @AuraEnabled
    public static void addBooks(Id bookId, Integer quantity) {
        List<Book_Copy__c> copies = new List<Book_Copy__c>();
        for (Integer i=0; i<quantity; i++) {
            Book_Copy__c copy = new Book_Copy__c(Condition__c='New', Book__c=bookId, Branch__c=BranchHelper.getBranch().Id);
            copies.add(copy);
        }
        insert copies;
    }

    @AuraEnabled
    public static string checkoutBook(String bookNo, String cardNo){
        Book_Copy__c copy;
        try {
            copy = [SELECT Id,Branch__c,Borrower__c,Condition__c,Book__c FROM Book_Copy__c WHERE Name=:bookNo];
        } catch (QueryException e) {
            throw new InputException('Invalid Book Serial Number');
        }
        if ((copy.Branch__c == null) && (copy.Borrower__c != null)) {
            throw new InputException('Book is already checked out');
        }

        RecordType borrowerRecordType = [SELECT Id FROM RecordType WHERE SobjectType='Contact' AND Name='Borrower'];
        Contact borrower;
        try {
            borrower = [SELECT Id,Name FROM Contact WHERE Card_Number__c=:cardNo AND RecordTypeId=:borrowerRecordType.Id];
        } catch (QueryException e) {
            throw new InputException('Invalid Card Number');
        }
        
        copy.Branch__c = null;
        copy.Borrower__c = borrower.Id;
        if (copy.Condition__c == 'New') {
            copy.Condition__c = 'Used';
        }

        Update copy;
        Insert new Loan__c(Book_Copy__c = copy.Id, Borrower__c = borrower.Id);
        
        Book__c book = [SELECT Name FROM Book__c WHERE Id=:copy.Book__c];
        return 'Checked out copy of ' + book.Name + ' to ' + borrower.Name;
    }

    @AuraEnabled(cacheable=true)
    public static Id getUserId() {
        return UserInfo.getUserId();
    }
}