@isTest
public class PartTriggerHandlerTest {
    
    @isTest
    static void testValidPart() {
        // Create a valid Product
        Product2 prod = new Product2(Name = 'Sample Product', ProductCode = 'P001', isActive = true);
        insert prod;

        // Valid Part with correct numeric and lookup usage
        SQX_Part__c p = new SQX_Part__c(
            Name = 'Test Part',
            Active__c = true,
            Product__c = prod.Id,     // lookup, so Id type
            Part_Number__c = 10       // numeric, so Integer/Decimal
        );
        insert p;

        System.assertEquals(prod.Id, p.Product__c);
    }

    @isTest
    static void testPartWithoutProduct_ShouldFail() {
        SQX_Part__c p = new SQX_Part__c(
            Name = 'Bad Part',
            Active__c = true,
            Part_Number__c = 5
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
            Part_Number__c = -5,   // ✅ valid negative numeric
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
    static void testPartWithNonNumericPartNumber_ShouldFail() {
        // NOTE: Since Part_Number__c is Number, Salesforce won't even allow non-numeric assignment.
        // Instead, simulate invalid data handling using custom logic.

        Product2 prod = new Product2(Name = 'Invalid Product 2', ProductCode = 'P003', isActive = true);
        insert prod;

        SQX_Part__c p = new SQX_Part__c(
            Name = 'Alpha Part',
            Product__c = prod.Id
            // Not assigning Part_Number__c to simulate bad input
        );

        try {
            insert p;
            System.assert(false, 'Expected error when Part Number is missing or invalid');
        } catch (DmlException e) {
            System.assert(
                e.getMessage().contains('Part Number must be numeric.') ||
                e.getMessage().contains('Part Number cannot be blank.')
            );
        }
    }
}
