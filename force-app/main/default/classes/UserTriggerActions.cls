public inherited sharing class UserTriggerActions {
    public static void createRecordsForLibrarians(List<User> users) {
        Profile librarianProfile = [SELECT Id FROM Profile WHERE Name='Librarian'];
        List<Id> userIds = new List<Id>();

        for (User u : users) {
            if (u.ProfileId == librarianProfile.Id) {
                userIds.add(u.Id);
            }
        }

        if (!userIds.isEmpty()) System.enqueueJob(new LibrarianRecordCreatorQueueable(userIds));
    }

    public static void createDeleteUpdateRecordsForLibrarians(List<User> newusers, Map<Id,User> oldusers) {
        Profile librarianProfile = [SELECT Id FROM Profile WHERE Name='Librarian'];
        List<Id> active = new List<Id>();
        List<Id> inactive = new List<Id>();
        List<Id> nameChanged = new List<Id>();

        for (User u : newusers) {
            if (u.ProfileId == librarianProfile.Id) {
                User oldu = oldusers.get(u.Id);
                if (u.IsActive && !oldu.IsActive) {
                    active.add(u.Id);
                }
                else if (!u.IsActive && oldu.IsActive) {
                    inactive.add(u.Id);
                }
                else if (u.IsActive && ((u.FirstName != oldu.FirstName) || (u.LastName != oldu.LastName))) {
                    nameChanged.add(u.Id);
                }
            }
        }

        if (!active.isEmpty()) System.enqueueJob(new LibrarianRecordCreatorQueueable(active));
        if (!inactive.isEmpty()) System.enqueueJob(new LibrarianRecordDeleterQueueable(inactive));
        if (!nameChanged.isEmpty()) System.enqueueJob(new LibrarianRecordUpdaterQueueable(nameChanged));
    }
}