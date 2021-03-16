trigger ContactTrigger on Contact (after insert, after update, after delete) {
    if (Trigger.isAfter && Trigger.isInsert) {
        ContactTriggerActions.createLibrarianTasks(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        ContactTriggerActions.updateLibrarianTasks(Trigger.new, Trigger.oldMap);
    }
}