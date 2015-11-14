public class InsightsController {

    @AuraEnabled
    public static List<Insight__c> getInsights() {
        return [SELECT Id, Name, Data_Source__c FROM Insight__c ORDER BY CreatedDate ASC];
    }
    
}