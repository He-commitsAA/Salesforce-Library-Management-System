public inherited sharing class UserTriggerActions {
    public static void createContactsForLibrarians(List<User> users) {
        System.enqueueJob(new LibrarianContactCreatorQueueable(users));
    }

    public static void updateContactsForLibrarians(List<User> users) {
        RecordType librarianRecordType = [SELECT Id FROM RecordType WHERE SobjectType='Contact' AND Name='Librarian'];
        Profile librarianProfile = [SELECT Id FROM Profile WHERE Name='Librarian'];
        for (User u : users) {
            
        }
    }
}
