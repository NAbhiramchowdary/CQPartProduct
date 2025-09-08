public with sharing class PartTriggerHandler {
    public static void validateParts(List<Part__c> newParts) {
        for (Part__c part : newParts) {
            // Example validation: Product__c field cannot be blank
            if (String.isBlank(part.Product__c)) {
                part.addError('Product field cannot be blank.');
            }

            // Example validation: Part Number should not be negative
            if (part.Part_Number__c != null && part.Part_Number__c < 0) {
                part.addError('Part Number cannot be negative.');
            }
        }
    }
}
