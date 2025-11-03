trigger LeadTrigger on Lead (before insert, after insert) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            LeadTriggerHandler.beforeInsert(Trigger.new);
        }
    }
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            LeadTriggerHandler.afterInsert(Trigger.new);
        }
    }
}