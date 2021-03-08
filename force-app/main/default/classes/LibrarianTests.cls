@isTest
public inherited sharing class LibrarianTests {
    @TestSetup
    static void makeData(){
        test.startTest();
        Insert TestDataFactory.createLibrarian();
        test.stopTest();
    }

    @isTest
    public static void librarianContactTest() {
        RecordType librarianRecordType = [SELECT Id FROM RecordType WHERE SobjectType='Contact' AND Name='Librarian'];
        Profile librarianProfile = [SELECT Id FROM Profile WHERE Name='Librarian'];

        User libUser = [SELECT Id,Name,Email FROM User WHERE ProfileId=:librarianProfile.Id LIMIT 1];
        Contact libContact = [SELECT Name,Email FROM Contact WHERE RecordTypeId=:librarianRecordType.Id AND Librarian_User__c=:libUser.Id];

        System.assertEquals(libUser.Name, libContact.Name);
        System.assertEquals(libUser.Email, libContact.Email);
    }
}
