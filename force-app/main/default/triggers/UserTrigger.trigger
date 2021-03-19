trigger UserTrigger on User (after insert, after update) {
    if (Trigger.isAfter && Trigger.isInsert) {
        UserTriggerActions.createContactsForLibrarians(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        UserTriggerActions.createDeleteContactsForLibrarians(Trigger.new, Trigger.oldMap);
        UserTriggerActions.updateContactsForLibrarians(Trigger.new);
    }
}