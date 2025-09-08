trigger PartTrigger on SQX_Part__c (before insert, before update) {
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        PartTriggerHandler.validateParts(Trigger.new);
    }
}
