public with sharing class LibrarianRecordUpdaterQueueable implements Queueable {
    private List<Id> users;

    public LibrarianRecordUpdaterQueueable(List<Id> users) {
        this.users = users;
    }

    public void execute(QueueableContext context) {
        //Trigger a workflow rule that updates a librarian's name
        Update [SELECT Id FROM Librarian__c WHERE User__c IN :users FOR UPDATE];
    }
}
