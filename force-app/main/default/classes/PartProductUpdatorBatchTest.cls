@isTest
private class PartProductUpdatorBatchTest {
    
    @testSetup
    static void setupData() {
        // Existing Product for PartA
        insert new Product2(
            Name = 'PartA',
            ProductCode = 'P1001',
            IsActive = true
        );

        // Parts
        insert new SQX_Part__c(
            Name = 'PartA',
            Part_Number__c = 'P1001'
        );
        insert new SQX_Part__c(
            Name = 'PartB',
            Part_Number__c = 'P2002'
        );
    }
    
    static testMethod void testExistingProductLink_SystemAdmin() {
        Test.startTest();
        Database.executeBatch(new PartProductUpdatorBatch(), 200);
        Test.stopTest();
        
        // Query outside loop
        Map<String, SQX_Part__c> parts = new Map<String, SQX_Part__c>(
            [SELECT Name, Product__c FROM SQX_Part__c WHERE Name IN ('PartA','PartB')]
        );
        
        System.assertNotEquals(null, parts.get('PartA').Product__c,
            'PartA should be linked to existing Product');
    }
    
    static testMethod void testNewProductCreated_SystemAdmin() {
        Test.startTest();
        Database.executeBatch(new PartProductUpdatorBatch(), 200);
        Test.stopTest();
        
        // Query outside loop
        SQX_Part__c partB = [SELECT Name, Product__c FROM SQX_Part__c WHERE Name = 'PartB' LIMIT 1];
        System.assertNotEquals(null, partB.Product__c,
            'PartB should create and link a new Product');
        
        Product2 newProd = [SELECT Name, ProductCode FROM Product2 WHERE Id = :partB.Product__c];
        System.assertEquals('PartB', newProd.Name, 'New Product Name must match Part Name');
        System.assertEquals('P2002', newProd.ProductCode, 'New Product Code must match Part Number');
    }
    
    static testMethod void testUnauthorizedUserBlocked() {
        // Query profile outside loop
        Profile stdProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User stdUser = new User(
            Alias = 'stdusr',
            Email = 'stdusr@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/New_York',
            ProfileId = stdProfile.Id,
            Username = 'stdusr' + System.currentTimeMillis() + '@test.com'
        );
        insert stdUser;
        
        Test.startTest();
        System.runAs(stdUser) {
            Boolean exceptionThrown = false;
            try {
                Database.executeBatch(new PartProductUpdatorBatch(), 200);
            } catch (Exception e) {
                exceptionThrown = true;
            }
            System.assert(exceptionThrown,
                'Unauthorized user should not be able to run the batch');
        }
        Test.stopTest();
    }

    static testMethod void testCQProductAdminUserAccess() {
        // Query profile and permission set once
        Profile stdProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        PermissionSet cqPerm = [SELECT Id FROM PermissionSet WHERE Name = 'CQ_Product_Admin' LIMIT 1];
        
        User psUser = new User(
            Alias = 'psuser',
            Email = 'psuser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'PSUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/New_York',
            ProfileId = stdProfile.Id,
            Username = 'psuser' + System.currentTimeMillis() + '@test.com'
        );
        insert psUser;

        // Assign permission set
        insert new PermissionSetAssignment(
            AssigneeId = psUser.Id,
            PermissionSetId = cqPerm.Id
        );

        // Run batch as this user
        Test.startTest();
        System.runAs(psUser) {
            Database.executeBatch(new PartProductUpdatorBatch(), 200);
        }
        Test.stopTest();

        // Query outside loop
        SQX_Part__c partB = [SELECT Product__c FROM SQX_Part__c WHERE Name = 'PartB' LIMIT 1];
        System.assertNotEquals(null, partB.Product__c,
            'CQ_Product_Admin user should be allowed to run the batch');
    }
}