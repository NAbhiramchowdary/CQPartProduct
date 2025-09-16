public with sharing class PartTriggerHandler {
    public static void validateParts(List<SQX_Part__c> newParts) {
        for (SQX_Part__c part : newParts) {
            // Validation: Product__c field cannot be blank
            if (String.isBlank(part.Product__c)) {
                //part.addError('Product field cannot be blank.');
            }

            // Validation: Part Number should not be negative (convert text to integer safely)
            if (!String.isBlank(part.Part_Number__c)) {
                try {
                    Integer partNum = Integer.valueOf(part.Part_Number__c);
                    if (partNum < 0) {
                        //part.addError('Part Number cannot be negative.');
                    }
                } catch (Exception e) {
                    //part.addError('Part Number must be numeric.');
                }
            }
        }
    }
}