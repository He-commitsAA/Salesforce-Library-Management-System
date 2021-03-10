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
        try {
            Book_Copy__c copy = [SELECT Id FROM Book_Copy__c WHERE Name=:bookNo];
            if (copy == null) {
                throw new AuraHandledException('Invalid Book Serial Number');
            } else if ((copy.Branch__c == null) && (copy.Borrower__c != null)) {
                throw new AuraHandledException('Book is already checked out');
            }

            
            Contact borrower = [SELECT Id,Name FROM Contact WHERE Card_Number__c=:cardNo];
            if (borrower == null) {
                throw new AuraHandledException('Invalid Card Number');
            }
            
            copy.Branch__c = null;
            copy.Borrower__c = borrower.Id;
            //TODO: Change new books to used

            Insert new Loan__c(Book_Copy__c = copy.Id, Borrower__c = borrower.Id);
            Update copy;
            
            Book__c book = [SELECT Name FROM Book__c WHERE Id=:copy.Book__c];
            return 'Checked out copy of ' + book.Name + ' to ' + borrower.Name;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Id getUserId() {
        return UserInfo.getUserId();
    }
}