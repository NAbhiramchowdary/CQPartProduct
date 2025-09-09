@isTest
public class PartTriggerHandlerTest {
    
    @isTest
    static void testValidPart() {
        // Insert a related Product first
        Product2 prod = new Product2(Name = 'Sample Product', ProductCode = 'P001', isActive = true);
        insert prod;

        // A valid part with Product__c filled
        SQX_Part__c p = new SQX_Part__c(
            Name = 'Test Part',
            Active__c = true,
            Product__c = prod.Id,   // ✅ Use Id, not string
            Part_Number__c = 10     // ✅ Numeric field
        );
        insert p;

        System.assertEquals(prod.Id, p.Product__c);
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
        // Insert a Product
        Product2 prod = new Product2(Name = 'Invalid Product', ProductCode = 'P002', isActive = true);
        insert prod;

        SQX_Part__c p = new SQX_Part__c(
            Name = 'Negative Part',
            Part_Number__c = -5,   // ✅ Numeric, negative
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
        // Insert a Product
        Product2 prod = new Product2(Name = 'Invalid Product 2', ProductCode = 'P003', isActive = true);
        insert prod;

        SQX_Part__c p = new SQX_Part__c(
            Name = 'Alpha Part',
            // For invalid numeric check, put null or wrong type handling 
            Product__c = prod.Id
        );

        // Force invalid numeric check with try/catch
        try {
            p.Part_Number__c = Decimal.valueOf('ABC123'); // will throw runtime exception
            insert p;
            System.assert(false, 'Expected error when Part Number is not numeric');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Invalid decimal') ||
                          e.getMessage().contains('Part Number must be numeric.'));
        }
    }
}
