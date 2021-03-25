public with sharing class TaskCreator {
    
    public static void createRemovalTask(List<Book_Copy__c> bcs){

        List<Branch__c> branches = [select id,name from branch__c];
        List<Task> tasks = new List<Task>();
        for(Branch__c branch: branches){
            String toRemove = 'Remove book copies with the following serial numbers from circulation:\n';
            for(Book_Copy__c bc: bcs){
                if(bc.branch__c == branch.id){
                    toRemove += bc.name+'\n';
                }
            }
            Id librarianContactId = [select id from contact where branch__c=:branch.id limit 1].id;
            Id librarianUserId = [select librarian_user__c from contact where id =: librarianContactId limit 1].librarian_user__c;
            tasks.add(new Task(Subject = 'Remove from Circulation', OwnerId = librarianUserId, Priority = 'Normal',
                ActivityDate = Date.today().addDays(7), Status = 'Not Started', Description = toRemove, WhatId = branch.id ));
        }
        insert tasks;

    }
        
}