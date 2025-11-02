trigger OpportunityTrigger on Opportunity (before update, after update, after insert) {
    if (Trigger.isBefore && Trigger.isUpdate) {
        OpportunityTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        OpportunityTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }
    if (Trigger.isAfter && Trigger.isInsert) {
        OpportunityTriggerHandler.afterInsert(Trigger.new);
    }
}
