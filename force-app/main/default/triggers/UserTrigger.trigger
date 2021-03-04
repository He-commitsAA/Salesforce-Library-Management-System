trigger UserTrigger on User (after insert) {
    if (Trigger.isAfter && Trigger.isInsert) {
        UserTriggerActions.createContactsForLibrarians(Trigger.new);
    }
}