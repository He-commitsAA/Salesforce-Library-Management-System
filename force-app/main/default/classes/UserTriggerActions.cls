public inherited sharing class UserTriggerActions {
    public static void createContactsForLibrarians(List<User> users) {
        System.enqueueJob(new LibrarianContactCreatorQueueable(users));
    }

    public static void updateContactsForLibrarians(List<User> users) {
        Map<Id, Contact> librarians = new Map<Id, Contact>();
        RecordType librarianRecordType = [SELECT Id FROM RecordType WHERE SobjectType='Contact' AND Name='Librarian'];
        Profile librarianProfile = [SELECT Id FROM Profile WHERE Name='Librarian'];
        List<Contact> contacts = [SELECT Id FROM Contact WHERE RecordTypeId = :librarianRecordType.Id];
        for (Contact c : contacts) librarians.put(c.Librarian_User__c, c);
        List<Contact> changedContacts = new List<Contact>();

        for (User u : users) {
            if (u.ProfileId == librarianProfile.Id) {
                Contact l = librarians.get(u.Id);
                l.FirstName = u.FirstName;
                l.LastName = u.LastName;
                l.Email = u.Email;
                changedContacts.add(l);
            }
        }
        update l;
    }
}