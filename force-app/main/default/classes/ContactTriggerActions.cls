public with sharing class ContactTriggerActions {
    private static final String librarianTaskSubject = 'Assign Librarian to Branch';
    
    public static void enforceLibrarianBranch(List<Contact> contacts) {
        RecordType librarianRecordType = [SELECT Id FROM RecordType WHERE SobjectType='Contact' AND Name='Librarian'];
        
        for (Contact con : contacts) {
            if ((con.RecordTypeId == librarianRecordType.Id) && (con.Branch__c == null)) {
                con.Branch__c.addError('Librarians must be associated with a Branch');
            }
        }
    }

    public static void createLibrarianTasks(List<Contact> contacts) {
        RecordType librarianRecordType = [SELECT Id FROM RecordType WHERE SobjectType='Contact' AND Name='Librarian'];
        List<Task> tasks = new List<Task>();

        for (Contact con : contacts) {
            if ((con.RecordTypeId == librarianRecordType.Id) && (con.Branch__c == null)) {
                tasks.add(new Task(
                    Subject = librarianTaskSubject,
                    Status = 'Not Started',
                    Priority = 'High',
                    ActivityDate = Date.today(),
                    WhoId = con.Id
                ));
            }
        }

        Insert tasks;
    }

    public static void updateLibrarianTasks(List<Contact> contacts, Map<Id,Contact> oldContactsMap) {
        RecordType librarianRecordType = [SELECT Id FROM RecordType WHERE SobjectType='Contact' AND Name='Librarian'];
        List<Id> contactIds = new List<Id>(); //list of contacts with tasks that should be completed

        for (Contact con : contacts) {
            if (con.RecordTypeId == librarianRecordType.Id) {
                //if branch went from null to filled, add the contact to the list
                if ((con.Branch__c != null) && (oldContactsMap.get(con.Id).Branch__c == null)) {
                    contactIds.add(con.Id);
                }
            }
        }

        if (contactIds.size() > 0) {
            List<Task> tasks = [SELECT Status FROM Task WHERE Subject=:librarianTaskSubject AND Status!='Completed' AND WhoId IN :contactIds FOR UPDATE];
            for (task t : tasks) {
                t.Status = 'Completed';
            }
            Update tasks;
        }
    }
}
