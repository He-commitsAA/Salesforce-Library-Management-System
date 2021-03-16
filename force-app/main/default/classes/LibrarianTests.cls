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
        User libUser = [SELECT Id,Name,Email FROM User WHERE Profile.Name='Librarian' AND Name='Test Test' LIMIT 1];
        Contact libContact = [SELECT Name,Email FROM Contact WHERE RecordType.Name='Librarian' AND Librarian_User__c=:libUser.Id];

        System.assertEquals(libUser.Name, libContact.Name);
        System.assertEquals(libUser.Email, libContact.Email);
    }

    @isTest
    public static void createLibrarianTasksTest() {
        Task libTask = [SELECT Subject,Status,Priority FROM Task WHERE Who.RecordType.SobjectType='Contact' AND Who.RecordType.Name='Librarian'];
        
        System.assertEquals('Assign Librarian to Branch', libTask.Subject);
        System.assertEquals('Not Started', libTask.Status);
        System.assertEquals('High', libTask.Priority);
    }

    @isTest
    public static void updateLibrarianTasksTest() {
        Contact libContact = [SELECT Id,Branch__c FROM Contact WHERE RecordType.Name='Librarian'];
        Branch__c branch = [SELECT Id FROM Branch__c LIMIT 1];

        libContact.Branch__c = branch.Id;

        Update libContact;

        Task libTask = [SELECT Status FROM Task WHERE WhoId=:libContact.Id];
        System.assertEquals('Completed', libTask.Status);
    }
}
