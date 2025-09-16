@isTest
private class PartProductUpdatorBatchTest {
    
    @testSetup
    static void setupData() {
        List<Product2> products = new List<Product2>{
            new Product2(Name = 'PartA', ProductCode = 'P1001', IsActive = true)
        };
        
        List<SQX_Part__c> parts = new List<SQX_Part__c>{
            new SQX_Part__c(Name = 'PartA', Part_Number__c = 'P1001'),
            new SQX_Part__c(Name = 'PartB', Part_Number__c = 'P2002')
        };
        
        insert products;
        insert parts;
    }

    static testMethod void testExistingProductLink_SystemAdmin() {
        Test.startTest();
        Database.executeBatch(new PartProductUpdatorBatch(), 200);
        Test.stopTest();
        
        Product2 prodA = [SELECT Id FROM Product2 WHERE Name = 'PartA' LIMIT 1];
        SQX_Part__c partA = [SELECT Name, Product__c FROM SQX_Part__c WHERE Name = 'PartA' LIMIT 1];

        System.assertEquals(prodA.Id, partA.Product__c,'PartA should be linked to existing Product');
    }

    static testMethod void testUnauthorizedUserBlocked() {
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
            try {
                String cronExp = '0 0 6 * * ?';
                System.schedule('testPartUpdatorBatch',cronExp , new PartProductUpdatorBatch());
            } catch (Exception e) {
                System.assertEquals(e.getMessage(), 'Access Denied: Current user does not have required permissions.');
            }
            
        }
        Test.stopTest();
    }

    static testMethod void testCQProductAdminUserAccess() {
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

        insert new PermissionSetAssignment(
            AssigneeId = psUser.Id,
            PermissionSetId = cqPerm.Id
        );

        Test.startTest();
        System.runAs(psUser) {
            String cronExp = '0 0 6 * * ?';
            String jobID = System.schedule('testPartUpdatorBatch',cronExp , new PartProductUpdatorBatch());
            CronTrigger ct = [SELECT CronJobDetail.Name, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobID];
            System.assertEquals('testPartUpdatorBatch', ct.CronJobDetail.Name);
        }
        Test.stopTest();
    }
}