public inherited sharing class UserTriggerActions {
    public static void createContactsForLibrarians(List<User> users) {
        System.enqueueJob(new LibrarianContactCreatorQueueable(users));
    }

    public static void updateContactsForLibrarians(List<User> users) {
        Map<Id, Contact> librarians = new Map<Id, Contact>();
        RecordType librarianRecordType = [SELECT Id FROM RecordType WHERE SobjectType='Contact' AND Name='Librarian'];
        Profile librarianProfile = [SELECT Id FROM Profile WHERE Name='Librarian'];
        List<Contact> contacts = [SELECT Id,Librarian_User__c,FirstName,LastName,Email FROM Contact WHERE RecordTypeId = :librarianRecordType.Id];
        for (Contact c : contacts) librarians.put(c.Librarian_User__c, c);
        List<Contact> changedContacts = new List<Contact>();

        for (User u : users) {
            if (u.ProfileId == librarianProfile.Id) {
                if (librarians.containsKey(u.Id) && u.IsActive) {
                    Contact l = librarians.get(u.Id);
                    l.FirstName = u.FirstName;
                    l.LastName = u.LastName;
                    l.Email = u.Email;
                    changedContacts.add(l);
                }
            }
        }
        update changedContacts;
    }

    public static void createDeleteContactsForLibrarians(List<User> newusers, Map<Id,User> oldusers) {
        Profile librarianProfile = [SELECT Id FROM Profile WHERE Name='Librarian'];
        List<User> active = new List<User>();
        List<User> inactive = new List<User>();

        for (User u : newusers) {
            if (u.ProfileId == librarianProfile.Id) {
                if (u.IsActive && !oldusers.get(u.Id).IsActive) {
                    active.add(u);
                }
                else if (!u.IsActive && oldusers.get(u.Id).IsActive) {
                    inactive.add(u);
                }
            }
        }

        createContactsForLibrarians(active);
        deleteContactsForLibrarians(inactive);
    }

    private static void deleteContactsForLibrarians(List<User> users) {
        System.enqueueJob(new LibrarianContactDeleterQueueable(users));
    }
}