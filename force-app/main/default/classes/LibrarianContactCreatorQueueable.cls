public inherited sharing class LibrarianContactCreatorQueueable implements Queueable {
    private List<User> users;
    
    public LibrarianContactCreatorQueueable(List<User> users) {
        this.users = users;
    }
    
    public void execute(QueueableContext context) {
        RecordType librarianRecordType = [SELECT Id FROM RecordType WHERE SobjectType='Contact' AND Name='Librarian'];
        Profile librarianProfile = [SELECT Id FROM Profile WHERE Name='Librarian'];
        List<Contact> contacts = new List<Contact>();

        for (User u : users) {
            if (u.ProfileId == librarianProfile.Id) {
                contacts.add(new Contact(
                    Librarian_User__c = u.Id,
                    RecordTypeId = librarianRecordType.Id,
                    FirstName = u.FirstName,
                    LastName = u.LastName,
                    Email = u.Email
                ));
            }
        }

        Insert contacts;
    }
}
