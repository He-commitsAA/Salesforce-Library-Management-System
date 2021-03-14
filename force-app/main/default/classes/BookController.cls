public with sharing class BookController {
    @AuraEnabled(cacheable=true)
    public static List<Book__c> getBookList() {
        return [select id,Name,Author__c from Book__c];
    }

    @AuraEnabled(cacheable=true)
    public static List<Book_Copy__c> getCheckedOutBooks() {
        return [select id,Name,Book__c,Borrower__c from Book_Copy__c where Borrower__c != null];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Loan__c> getLoans() {
        return [select id,Name,Book_Copy__c,Borrower__c,Due__c from Loan__c where Returned__c = false];
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> getBorrowers() {
        Id borrowerId = [select id from RecordType where Name='Borrower'].Id;
        return [select id,Name from Contact where RecordTypeId = :borrowerId];
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

    @AuraEnabled(cacheable=true)
    public static Id getUserId() {
        return UserInfo.getUserId();
    }

    @AuraEnabled
    public static void renewLoan(Id loanId, Integer days) {
        Loan__c loan = [select id,Due__c from Loan__c where Id = :loanId LIMIT 1].get(0);
        loan.Due__c = loan.Due__c.addDays(days);
        update loan;
    }
}