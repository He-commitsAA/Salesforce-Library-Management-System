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
        Branch__c branch = BranchHelper.getBranch();
        List<Book_Copy__c> copies = new List<Book_Copy__c>();
        for (Integer i=0; i<quantity; i++) {
            Book_Copy__c copy = new Book_Copy__c(Condition__c='New', Book__c=bookId, Branch__c=branch.Id);
            copies.add(copy);
        }
        insert copies;
    }

    @AuraEnabled
    public static string checkoutBook(String bookNo, String cardNo){
        Book_Copy__c copy;
        try {
            copy = [SELECT Id,Branch__c,Borrower__c,Condition__c,Book__r.Name,Holder__c FROM Book_Copy__c WHERE Name=:bookNo];
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
        try{
            Insert new Loan__c(Book_Copy__c = copy.Id, Borrower__c = borrower.Id);
        } catch (Exception e) {
            Contact holder = [SELECT name FROM Contact WHERE id =: copy.Holder__c LIMIT 1];
            throw new InputException('Book with hold cannot be checked out except by Holder: '+ holder.name);
        }
        
        return 'Checked out copy of ' + copy.Book__r.Name + ' to ' + borrower.Name;
    }

    @AuraEnabled(cacheable=true)
    public static Id getUserId() {
        return UserInfo.getUserId();
    }

    @AuraEnabled
    public static void renewLoan(Id loanId, Integer days) {
        Loan__c loan = [select id,Due__c,Book_Copy__c from Loan__c where Id = :loanId LIMIT 1].get(0);
        loan.Due__c = loan.Due__c.addDays(days);
        try{
            update loan;
        } catch (Exception e) {
            Book_Copy__c copy = [SELECT id,Holder__c FROM Book_Copy__c WHERE id =: loan.Book_Copy__C LIMIT 1];
            Contact holder = [SELECT name FROM Contact WHERE id =: copy.Holder__c LIMIT 1];
            throw new InputException('Book with hold cannot be renewed except by Holder: '+ holder.name);
        }
    }

    @AuraEnabled
    public static string returnBook(String bookNo, Boolean damaged){
        Loan__c loan;
        Book_copy__c copy;
        try {
            copy = [SELECT Id,Name,Branch__c,Borrower__c,Condition__c,Book__c FROM Book_Copy__c WHERE Name=:bookNo LIMIT 1 FOR UPDATE];
        } catch (QueryException e) {
            throw new InputException('Invalid serial number');
        }
        try {
            loan = [SELECT Id,Name,Borrower__c,Book_Copy__c,Returned__c FROM Loan__c WHERE Book_copy__c=:copy.id LIMIT 1 FOR UPDATE];
        } catch (QueryException e) {
            throw new InputException('Cannot find loan');
        }
        loan.Returned__c = true;
        copy.Borrower__c = null;
        copy.Branch__c = BranchHelper.getBranch().id;
        if(damaged == true){
            copy.Condition__c = 'Damaged';
        }
        update loan;
        update copy;
        return 'Return successful.';
    }
}