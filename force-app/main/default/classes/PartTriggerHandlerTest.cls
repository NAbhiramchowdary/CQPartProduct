@isTest
public class PartTriggerHandlerTest {
    
    @isTest
    static void testValidPart() {
        Product2 prod = new Product2(Name = 'Sample Product', ProductCode = 'P001', isActive = true);
        insert prod;

        SQX_Part__c p = new SQX_Part__c(
            Name = 'Test Part',
            Active__c = true,
            Product__c = prod.Id,
            Part_Number__c = 10   // ✅ Correct: number, no quotes
        );
        insert p;

        System.assertEquals(prod.Id, p.Product__c);
    }

    @isTest
    static void testPartWithoutProduct_ShouldFail() {
        SQX_Part__c p = new SQX_Part__c(
            Name = 'Bad Part',
            Active__c = true,
            Part_Number__c = 5    // ✅ Number, no quotes
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
        Product2 prod = new Product2(Name = 'Invalid Product', ProductCode = 'P002', isActive = true);
        insert prod;

        SQX_Part__c p = new SQX_Part__c(
            Name = 'Negative Part',
            Part_Number__c = -5,   // ✅ Correct: number, no quotes
            Product__c = prod.Id
        );
        try {
            insert p;
            System.assert(false, 'Expected error when Part Number is negative');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Part Number cannot be negative.'));
        }
    }

    @isTest
    static void testPartWithMissingPartNumber_ShouldFail() {
        Product2 prod = new Product2(Name = 'Invalid Product 2', ProductCode = 'P003', isActive = true);
        insert prod;

        SQX_Part__c p = new SQX_Part__c(
            Name = 'No Number Part',
            Product__c = prod.Id
            // ✅ No Part_Number__c assigned, to simulate missing value
        );
        try {
            insert p;
            System.assert(false, 'Expected error when Part Number is missing');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Part Number cannot be blank.') 
                          || e.getMessage().contains('Part Number must be numeric.'));
        }
    }
}
