@isTest
public class PartTriggerHandlerTest {
    
    @isTest
    static void testValidPart() {
        SQX_Part__c p = new SQX_Part__c(
            Name = 'Test Part',
            Active__c = true,
            Product__c = 'Sample Product',
            Part_Number__c = '10' // as string
        );
        insert p;
        System.assertEquals('Sample Product', p.Product__c);
    }

    @isTest
    static void testPartWithoutProduct_ShouldFail() {
        SQX_Part__c p = new SQX_Part__c(
            Name = 'Bad Part',
            Active__c = true
        );
        try {
            insert p;
            System.assert(false, 'Expected error when Product__c is missing');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Product field cannot be blank.'));
        }
    }

    @isTest
    static void testPartWithNegativeNumber_ShouldFail() {
        SQX_Part__c p = new SQX_Part__c(
            Name = 'Negative Part',
            Part_Number__c = '-5', // as string
            Product__c = 'Invalid Product'
        );
        try {
            insert p;
            System.assert(false, 'Expected error when Part Number is negative');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Part Number cannot be negative.'));
        }
    }

    @isTest
    static void testPartWithNonNumericPartNumber_ShouldFail() {
        SQX_Part__c p = new SQX_Part__c(
            Name = 'Alpha Part',
            Part_Number__c = 'ABC123', // invalid text
            Product__c = 'Invalid Product'
        );
        try {
            insert p;
