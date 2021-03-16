public with sharing class ContactTriggerActions {
    private static final String librarianTaskSubject = 'Assign Librarian to Branch';
    
    private static Task newBranchTask(Id contactId) {
        return new Task(
            Subject = librarianTaskSubject,
            Status = 'Not Started',
            Priority = 'High',
            WhoId = contactId
        );
    }
    
    public static void createLibrarianTasks(List<Contact> contacts) {
        RecordType librarianRecordType = [SELECT Id FROM RecordType WHERE SobjectType='Contact' AND Name='Librarian'];
        List<Task> tasks = new List<Task>();

        for (Contact con : contacts) {
            if ((con.RecordTypeId == librarianRecordType.Id) && (con.Branch__c == null)) {
                tasks.add(newBranchTask(con.Id));
            }
        }

        Insert tasks;
    }

    public static void updateLibrarianTasks(List<Contact> contacts, Map<Id,Contact> oldContactsMap) {
        RecordType librarianRecordType = [SELECT Id FROM RecordType WHERE SobjectType='Contact' AND Name='Librarian'];
        List<Id> contactIds = new List<Id>();
        List<Task> newTasks = new List<Task>();

        for (Contact con : contacts) {
            if (con.RecordTypeId == librarianRecordType.Id) {
                Contact oldCon = oldContactsMap.get(con.Id);
                if ((con.Branch__c != null) && (oldCon.Branch__c == null)) {
                    contactIds.add(con.Id);
                } else if ((con.Branch__c == null) && (oldCon.Branch__c != null)) {
                    newTasks.add(newBranchTask(con.Id));
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

        Insert newTasks;
    }
}
