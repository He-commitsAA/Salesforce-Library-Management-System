trigger ContactTrigger on Contact (before update, after insert, after update) {
    if (Trigger.isBefore && Trigger.isUpdate) {
        ContactTriggerActions.enforceLibrarianBranch(Trigger.new);
    } else if (Trigger.isAfter && Trigger.isInsert) {
        ContactTriggerActions.createLibrarianTasks(Trigger.new);
    } else if (Trigger.isAfter && Trigger.isUpdate) {
        ContactTriggerActions.updateLibrarianTasks(Trigger.new, Trigger.oldMap);
    } 
}