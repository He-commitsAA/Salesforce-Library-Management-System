public inherited sharing class UserTriggerActions {
    public static void createContactsForLibrarians(List<User> users) {
        System.enqueueJob(new LibrarianContactCreatorQueueable(users));
    }
}
