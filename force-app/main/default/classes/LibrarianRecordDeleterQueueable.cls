public with sharing class LibrarianRecordDeleterQueueable implements Queueable {
    private List<Id> users;
    
    public LibrarianRecordDeleterQueueable(List<Id> users) {
        this.users = users;
    }

    public void execute(QueueableContext context) {
        Delete [SELECT Id FROM Librarian__c WHERE User__c IN :users];
    }
}