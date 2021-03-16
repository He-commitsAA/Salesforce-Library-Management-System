@isTest
public inherited sharing class LibrarianTests {
    @TestSetup
    static void makeData(){
        test.startTest();
        Insert TestDataFactory.createLibrarian();
        test.stopTest();
        Insert TestDataFactory.createBranch();
    }

    @isTest
    public static void librarianContactTest() {
        RecordType librarianRecordType = [SELECT Id FROM RecordType WHERE SobjectType='Contact' AND Name='Librarian'];
        Profile librarianProfile = [SELECT Id FROM Profile WHERE Name='Librarian'];

        User libUser = [SELECT Id,Name,Email FROM User WHERE ProfileId=:librarianProfile.Id AND Name='Test Test' LIMIT 1];
        Contact libContact = [SELECT Name,Email FROM Contact WHERE RecordTypeId=:librarianRecordType.Id AND Librarian_User__c=:libUser.Id];

        System.assertEquals(libUser.Name, libContact.Name);
        System.assertEquals(libUser.Email, libContact.Email);
    }

    @isTest
    public static void createLibrarianTasksTest() {
        RecordType librarianRecordType = [SELECT Id FROM RecordType WHERE SobjectType='Contact' and Name='Librarian'];
        Contact libContact = [SELECT Id FROM Contact WHERE RecordTypeId=:librarianRecordType.Id];

        Task libTask = [SELECT Subject,Status,Priority FROM Task WHERE WhoId=:libContact.Id];
        
        System.assertEquals('Assign Librarian to Branch', libTask.Subject);
        System.assertEquals('Not Started', libTask.Status);
        System.assertEquals('High', libTask.Priority);
    }

    @isTest
    public static void updateLibrarianTasksTest() {
        RecordType librarianRecordType = [SELECT Id FROM RecordType WHERE SobjectType='Contact' and Name='Librarian'];
        Contact libContact = [SELECT Id,Branch__c FROM Contact WHERE RecordTypeId=:librarianRecordType.Id];
        Branch__c branch = [SELECT Id FROM Branch__c LIMIT 1];

        libContact.Branch__c = branch.Id;

        Update libContact;

        Task libTask = [SELECT Status FROM Task WHERE WhoId=:libContact.Id];
        System.assertEquals('Completed', libTask.Status);
    }
}
