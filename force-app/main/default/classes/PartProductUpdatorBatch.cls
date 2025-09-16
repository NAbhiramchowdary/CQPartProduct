public class PartProductUpdatorBatch implements Database.Batchable<sObject>, Schedulable{
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT ID, Name, Product__c, Part_Number__c FROM SQX_Part__c ' +
            'WHERE Product__c = null AND Part_Number__c != null AND Name != null AND Id = \'a00aj00001IWQL7AAP\' ';
        return Database.getQueryLocator(query);
    }
    
    //considering partNumber is unique for each part
    public void execute(Database.BatchableContext bc, List<SQX_Part__c> inParts){
        List<SQX_Part__c> partsToUpdateList = new List<SQX_Part__c>();
        Set<String> partNames = new Set<String>();
        Set<String> partNumber = new Set<String>();
        Map<String, SQX_Part__c> nameNumbKeyToPartMap = new Map<String, SQX_Part__c>();
        
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
                insert nameNumbKeyToProdMap.values();
                for(String nameNumbKey : nameNumbKeyToProdMap.keySet()){
                    SQX_Part__c respPart = nameNumbKeyToPartMap.get(nameNumbKey);
                    respPart.Product__c = nameNumbKeyToProdMap.get(nameNumbKey).Id;
                    partsToUpdateList.add(respPart);
                }
            }
        }
        
        if(!partsToUpdateList.isEmpty()){
            update partsToUpdateList;
        }
    }
    
    public void finish(Database.BatchableContext bc) {}
    
    public void execute(SchedulableContext SC) {
        Database.executeBatch(new PartProductUpdatorBatch(), 200);
        
    }
}