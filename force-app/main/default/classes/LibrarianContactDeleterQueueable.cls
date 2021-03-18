public with sharing class LibrarianContactDeleterQueueable implements Queueable {
    private List<User> users;
    
    public LibrarianContactDeleterQueueable(List<User> users) {
        this.users = users;
    }

    public void execute(QueueableContext context) {
        RecordType librarianRecordType = [SELECT Id FROM RecordType WHERE SobjectType='Contact' AND Name='Librarian'];
        List<Contact> libContacts = [SELECT Id,Librarian_User__c FROM Contact WHERE RecordTypeId = :librarianRecordType.Id];
        Map<Id,Contact> librarians = new Map<Id, Contact>();
        for (Contact c : libContacts) librarians.put(c.Librarian_User__c, c);
        List<Contact> contactsToDelete = new List<Contact>();

        for (User u : users) {
            if (librarians.containsKey(u.Id)) {
                contactsToDelete.add(librarians.get(u.Id));
            }
        }
        delete contactsToDelete;
    }
}