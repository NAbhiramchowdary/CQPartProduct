trigger PartTrigger on Part__c (before insert, before update) {
    if(Trigger.isBefore) {
        if(Trigger.isInsert || Trigger.isUpdate) {
            PartTriggerHandler.validateParts(Trigger.new);
        }
    }
}

