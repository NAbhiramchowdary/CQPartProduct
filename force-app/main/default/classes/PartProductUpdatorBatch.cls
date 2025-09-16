public class PartProductUpdatorBatch implements Database.Batchable<sObject>, Schedulable{
    
    public static final String REQUIRED_PERMISSION_SET = 'CQ_Product_Admin';
    
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        try{
            String query = 'SELECT ID, Name, Product__c, Part_Number__c FROM SQX_Part__c ' +
                'WHERE Product__c = null AND Part_Number__c != null AND Name != null';
            return Database.getQueryLocator(query);
        }
        catch(Exception exp){
            System.debug('Exception in start(): ' + exp.getMessage());
            throw exp;
        }
        
    }
    
    //considering partNumber is unique for each part
    public void execute(Database.BatchableContext bc, List<SQX_Part__c> inParts){
        List<SQX_Part__c> partsToUpdateList = new List<SQX_Part__c>();
        Set<String> partNames = new Set<String>();
        Set<String> partNumber = new Set<String>();
        Map<String, SQX_Part__c> nameNumbKeyToPartMap = new Map<String, SQX_Part__c>();
        
        try{
            for(SQX_Part__c currPart : inParts){
                partNames.add(currPart.Name);
                partNumber.add(currPart.Part_Number__c);
                nameNumbKeyToPartMap.put(currPart.Name + ':' + currPart.Part_Number__c, currPart);
            }
            
            if(partNames.isEmpty() && partNumber.isEmpty()) return;
            
            for(Product2 curProd : [
                SELECT Id, Name, ProductCode 
                FROM Product2 
                WHERE Name IN :partNames AND ProductCode IN :partNumber AND IsActive = true
            ]){
                String nameNumbKey = curProd.Name + ':' + curProd.ProductCode;
                if(nameNumbKeyToPartMap.containsKey(nameNumbKey)){
                    SQX_Part__c respPart = nameNumbKeyToPartMap.get(nameNumbKey);
                    respPart.Product__c = curProd.Id;
                    partsToUpdateList.add(respPart);
                    nameNumbKeyToPartMap.remove(nameNumbKey);
                }
            }
            
            if(!nameNumbKeyToPartMap.isEmpty()){
                Map<String, Product2> nameNumbKeyToProdMap = new Map<String, Product2>();
                for(SQX_Part__c currPart : nameNumbKeyToPartMap.values()){
                    Product2 prodInst = new Product2(Name = currPart.Name, ProductCode = currPart.Part_Number__c, IsActive = true);
                    nameNumbKeyToProdMap.put(currPart.Name + ':' + currPart.Part_Number__c, prodInst);
                }
                
                if(!nameNumbKeyToProdMap.isEmpty()){
                    try{
                        insert nameNumbKeyToProdMap.values();
                    }
                    catch (Exception exp) {
                        System.debug('Failed to insert Products: ' + exp.getMessage());
                    }
                    
                    for(String nameNumbKey : nameNumbKeyToProdMap.keySet()){
                        SQX_Part__c respPart = nameNumbKeyToPartMap.get(nameNumbKey);
                        respPart.Product__c = nameNumbKeyToProdMap.get(nameNumbKey).Id;
                        partsToUpdateList.add(respPart);
                    }
                }
            }
            
            if (!partsToUpdateList.isEmpty()) {
                try {
                    update partsToUpdateList;
                } catch (Exception e) {
                    System.debug('Failed to update Parts: ' + e.getMessage());
                }
            }
            
        }catch (Exception e) {
            System.debug('Exception in execute: ' + e.getMessage());
        }
    }
    
    public void finish(Database.BatchableContext bc) {}
    
    public void execute(SchedulableContext SC) {
        if (!hasAccess()) {
            System.debug('Access Denied: Current user does not have required permissions.');
            return;
        }
        Database.executeBatch(new PartProductUpdatorBatch(), 200);
        
    }
    
    private Boolean hasAccess() {
        User currentUser = [
            SELECT Profile.Name,
            (SELECT PermissionSet.Name FROM PermissionSetAssignments WHERE PermissionSet.Name = :REQUIRED_PERMISSION_SET)
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
        
        return currentUser.Profile.Name == 'System Administrator'
            && !currentUser.PermissionSetAssignments.isEmpty();
    }
    
}