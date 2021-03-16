public inherited sharing class TestDataFactory {
    public static User createLibrarian() {
        Profile librarianProfile = [SELECT Id FROM Profile WHERE Name='Librarian'];
        return new User(
            ProfileId = librarianProfile.Id,
            FirstName = 'Test',
            LastName = 'Test',
            Alias = 'test',
            Email = 'test@test.com',
            Username = 'test@testasdf.com',
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US'
        );
    }

    public static Book__c createBook() {
        return new Book__c(
            Name = 'Test'
        );
    }

    public static Book_Copy__c createBookCopy(Id bookId, Id branchId) {
        return new Book_Copy__c(
            Condition__c = 'New',
            Book__c = bookId,
            Branch__c = branchId
        );
    }

    public static Branch__c createBranch() {
        return new Branch__c(
            Name = 'Test',
            Location__Latitude__s = 0,
            Location__Longitude__s = 0
        );
    }

    private static Integer borrowerNumber = 0;

    public static Contact createBorrower() {
        RecordType borrowerRecordType = [SELECT Id FROM RecordType WHERE SobjectType='Contact' AND Name='Borrower'];
        return new Contact(
            RecordTypeId = borrowerRecordType.Id,
            FirstName = 'Test',
            LastName = 'Test',
            Card_Number__c = String.valueOf(borrowerNumber++)
        );
    }

    public static void setLibrarianBranch(Id librarianUserId, Id branchId) {
        Contact librarianContact = [Select Id, Branch__c FROM Contact WHERE Librarian_User__c=:librarianUserId];
        librarianContact.Branch__c = branchId;
        Update librarianContact;
    }
}
