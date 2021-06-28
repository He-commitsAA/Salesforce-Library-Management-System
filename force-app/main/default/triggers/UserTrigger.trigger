trigger UserTrigger on User (after insert, after update) {
    if (Trigger.isAfter && Trigger.isInsert) {
        UserTriggerActions.createRecordsForLibrarians(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        UserTriggerActions.createDeleteUpdateRecordsForLibrarians(Trigger.new, Trigger.oldMap);
    }
}