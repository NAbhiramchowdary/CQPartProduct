public class PartProductUpdatorBatch implements Database.Batchable<sObject>, Schedulable {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Fetch Parts with no Product but valid Name & Part Number
        String query = 'SELECT Id, Name, Product__c, Part_Number__c FROM SQX_Part__c ' +
                       'WHERE Product__c = null AND Part_Number__c != null AND Name != null AND Id = \'a00aj00001IVN77AAH\'';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SQX_Part__c> inParts) {
        // Allow only System Admins or CQ_Product_Admin 
        if(!isAuthorizedUser()){
            throw new AuraHandledException('You are not authorized to run this batch.');
        }

        List<SQX_Part__c> partsToUpdateList = new List<SQX_Part__c>();
        Set<String> partNames = new Set<String>();
        Set<String> partNumbers = new Set<String>();
        Map<String, SQX_Part__c> nameNumbKeyToPartMap = new Map<String, SQX_Part__c>();

        // Collect Part names and numbers for lookup
        for(SQX_Part__c currPart : inParts){
            partNames.add(currPart.Name);
            partNumbers.add(currPart.Part_Number__c);
            nameNumbKeyToPartMap.put(currPart.Name + ':' + currPart.Part_Number__c, currPart);
        }

        if(partNames.isEmpty() && partNumbers.isEmpty()) return;

        try {
            // Find existing Products with matching Name & ProductCode
            for(Product2 curProd : [
                SELECT Id, Name, ProductCode 
                FROM Product2 
                WHERE Name IN :partNames AND ProductCode IN :partNumbers AND IsActive = true
            ]){
                String nameNumbKey = curProd.Name + ':' + curProd.ProductCode;
                if(nameNumbKeyToPartMap.containsKey(nameNumbKey)){
                    SQX_Part__c respPart = nameNumbKeyToPartMap.get(nameNumbKey);
                    respPart.Product__c = curProd.Id;
                    partsToUpdateList.add(respPart);
                    // Remove from map since already linked
                    nameNumbKeyToPartMap.remove(nameNumbKey);
                }
            }

            // Create new Products for unmatched Parts
            if(!nameNumbKeyToPartMap.isEmpty()){
                Map<String, Product2> nameNumbKeyToProdMap = new Map<String, Product2>();
                for(SQX_Part__c currPart : nameNumbKeyToPartMap.values()){
                    Product2 prodInst = new Product2(
                        Name = currPart.Name, 
                        ProductCode = currPart.Part_Number__c, 
                        IsActive = true
                    );
                    nameNumbKeyToProdMap.put(currPart.Name + ':' + currPart.Part_Number__c, prodInst);
                }

                if(!nameNumbKeyToProdMap.isEmpty()){
                    insert nameNumbKeyToProdMap.values();
                    for(String nameNumbKey : nameNumbKeyToProdMap.keySet()){
                        SQX_Part__c respPart = nameNumbKeyToPartMap.get(nameNumbKey);
                        respPart.Product__c = nameNumbKeyToProdMap.get(nameNumbKey).Id;
                        partsToUpdateList.add(respPart);
                    }
                }
            }

            // Update Parts with Product references
            if(!partsToUpdateList.isEmpty()){
                update partsToUpdateList;
            }

        } catch (Exception ex) {
            // Log exception in debug for troubleshooting
            System.debug('Error in PartProductUpdatorBatch: ' + ex.getMessage());
        }
    }

    public void finish(Database.BatchableContext bc) {}

    public void execute(SchedulableContext sc) {
        // Batch runs daily at 6 AM GMT (scheduled in Salesforce UI)
        Database.executeBatch(new PartProductUpdatorBatch(), 200);
    }

    // Check if current user is authorized
    private Boolean isAuthorizedUser(){
        // Check profile
        Profile p = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1];
        if(p.Name == 'System Administrator'){
            return true;
        }
        // Check permission set
        for(PermissionSetAssignment psa : [
            SELECT Id FROM PermissionSetAssignment 
            WHERE AssigneeId = :UserInfo.getUserId() 
            AND PermissionSet.Name = 'CQ_Product_Admin'
        ]){
            return true;
        }
        return false;
    }
}