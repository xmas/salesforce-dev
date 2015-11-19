public class InsightsController {

    @AuraEnabled
    public static List<Insight__c> getInsights() {
        return [SELECT Id, Name, Data_Source__c, Details__c, LastModifiedDate,
                Data_Source_Icon_URL__c, Directly_Responsible_User__c, OwnerId
                FROM Insight__c ORDER BY CreatedDate ASC];
    }

    @AuraEnabled
    public static Integer getFeedItemCountForObject(String object_id) {
        return [SELECT count() FROM FeedItem WHERE ParentId =:object_id];
    }

}
