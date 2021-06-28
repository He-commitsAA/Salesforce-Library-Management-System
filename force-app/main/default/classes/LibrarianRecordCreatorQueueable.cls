public inherited sharing class LibrarianRecordCreatorQueueable implements Queueable {
    private List<Id> users;
    
    public LibrarianRecordCreatorQueueable(List<Id> users) {
        this.users = users;
    }
    
    public void execute(QueueableContext context) {
        List<Librarian__c> librarians = new List<Librarian__c>();

        for (Id u : users) {
            librarians.add(new Librarian__c(User__c = u));
        }

        Insert librarians;
    }
}
