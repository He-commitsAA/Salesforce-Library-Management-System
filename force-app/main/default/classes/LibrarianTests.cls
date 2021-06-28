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
        Librarian__c librarian = [SELECT Name,Email__c FROM Librarian__c WHERE User__c=:libUser.Id];

        System.assertEquals(libUser.Name, librarian.Name);
        System.assertEquals(libUser.Email, librarian.Email__c);
    }

    @isTest
    public static void createLibrarianTasksTest() {
        Task libTask = [SELECT Subject,Status,Priority FROM Task WHERE What.Type='Librarian__c'];
        
        System.assertEquals('Assign Librarian to Branch', libTask.Subject);
        System.assertEquals('Not Started', libTask.Status);
        System.assertEquals('High', libTask.Priority);
    }

    @isTest
    public static void updateLibrarianTasksTest() {
        Branch__c branch = [SELECT Id FROM Branch__c LIMIT 1];
        Librarian__c librarian = [SELECT Id,Branch__c FROM Librarian__c FOR UPDATE];

        librarian.Branch__c = branch.Id;

        Update librarian;

        Task libTask = [SELECT Status FROM Task WHERE WhatId=:librarian.Id];
        System.assertEquals('Completed', libTask.Status);
    }
}
