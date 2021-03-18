trigger UserTrigger on User (after insert, after update) {
    if (Trigger.isAfter && Trigger.isInsert) {
        UserTriggerActions.createContactsForLibrarians(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        UserTriggerActions.updateContactsForLibrarians(Trigger.new);
    }
}