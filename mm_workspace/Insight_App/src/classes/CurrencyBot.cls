public with sharing class CurrencyBot {

    public CurrencyBot() {

        LedgerBot__c currencyBot = LedgerBotFactory.getLedgerBot('Currency');
        String lastResultString = currencyBot.Last_Result__c;
        System.debug(lastResultString);

        Map <String, Object> globalParams;
        if (lastResultString != null ) {
            globalParams = (Map <String, Object>) JSON.deserializeUntyped(lastResultString);
        } else {
            globalParams = new Map <String, Object> ();
        }

        // get all the SObjectTypes that have at least one Schema.DisplayType.Currency
        List <DataBotObjectFieldTuple> matchingTypes = DataBot.getTuplesForType(Schema.DisplayType.Currency);

        for (DataBotObjectFieldTuple tuple : matchingTypes) {

            String objectName = tuple.objType.getDescribe().getName();
            String fieldName = tuple.field.getDescribe().getName();
            String objField = objectName + '.' + fieldName;

            if (objField == 'DatacloudCompany.AnnualRevenue') {
                break;
            }

            // Currency:Object_Field params
            Map <String, Object> objFieldParams;
            if (globalParams.containsKey(objField)) {
                objFieldParams = (Map <String, Object>)globalParams.get(objField);
            }	else {
                objFieldParams = new Map<String, Object>();
            }

            // Currency:Object_Field:Instance params
            String INSTANCES = 'INSTANCES';
            Map <String, Object> objFieldInstanceParams;
            if (objFieldParams.containsKey(INSTANCES)) {
                objFieldInstanceParams = (Map <String, Object> )objFieldParams.get(INSTANCES);
            }	else {
                objFieldInstanceParams = new Map <String, Object> ();
            }

          //  System.debug(objectName+' /// '+ tuple.field.getDescribe().getName());

            String queryString = 'SELECT '+objectName + '.Id, '+ objField +
                ' FROM '+ objectName + ' WHERE '+ objField + ' > 0 ORDER BY '+ objField + ' DESC';
           // System.debug(queryString);

            List <SObject> objs = Database.query(queryString);

            String MAX_ID = 'MAX_ID';
            String MAX_VALUE = 'MAX_VALUE';

            // Currency:Object_Field:MAX_VALUE
            Map <String, Object> newObjFieldParams = compare(objFieldParams, objField, fieldName, MAX_ID, MAX_VALUE, objs);
            if (objFieldParams != newObjFieldParams) {
                System.debug('New max value of '+MAX_VALUE+' for '+fieldName+' accros all '+objectName+'s. The old max value was: '+objFieldParams.get(MAX_ID));
            }
        	objFieldParams = newObjFieldParams;

            // Currency:Object_Field:Instance:MAX_VALUE
            for (SObject inst : objs) {
             //   System.debug('do max value for instance: '+inst.get('Id'));
                // System.debug('inst pararms: '+objFieldInstanceParams);
                Map <String, Object> instanceParams;
                if (objFieldInstanceParams.containsKey(inst.Id)) {
                    instanceParams = (Map <String, Object>)objFieldInstanceParams.get(inst.Id);
                }	else {
                    instanceParams = new Map<String, Object>();
                }
                List <SObject> instList = new List <SObject> ();
                instList.add(inst);
                instanceParams = compare(instanceParams, objField, fieldName, MAX_ID, MAX_VALUE, instList);
                if (instanceParams.keySet().size() > 0) {
                    objFieldInstanceParams.put(inst.Id, instanceParams);
                }
            }
            if (objFieldInstanceParams.keySet().size() > 0 ) {
                objFieldParams.put(INSTANCES, objFieldInstanceParams);
            }

            // Currency:Object_Field
            globalParams.put(objField, objFieldParams);
        }

        //System.debug(JSON.serialize(lastGlobalParams));
        System.debug('upsert the global params');
        currencyBot.Last_Result__c = JSON.serialize(globalParams);
        currencyBot.Last_Result_Time__c = system.now();
        upsert currencyBot;
    }

    private Map <String, Object> compare(Map <String, Object> currentParams,
                                         String objField,
                                         String fieldName,
                                         String idKeyName,
                                         String valueKeyName,
                                         List <SObject> objs )
    {
        if (objs.size() == 0) {
           // System.debug('No objects returned for Currency:'+'objField'+':'+objField);
            return currentParams;
        }

        SObject currentObject = objs.get(0);

        String currentMaxId = (String)currentObject.Id;
        Double currentMaxValue = Double.valueOf(currentObject.get(fieldName));

        String lastMaxId = '';
        Double lastMaxValue = 0;
        if (currentParams.containsKey(valueKeyName) && currentParams.containsKey(idKeyName) ) {
            lastMaxId = (String)currentParams.get(idKeyName);
            lastMaxValue = Double.valueOf(currentParams.get(valueKeyName));
          //  System.debug('OLD VALUE ON ID: '+lastMaxId+' VALUE: '+lastMaxValue);
        }
        //System.debug('COMPARE ID: '+lastMaxId+' LAST VALUE: '+lastMaxValue + ' CURRENT: '+currentMaxValue);


        if (currentMaxValue > lastMaxValue) {
            System.debug('NEW MAX VALUE FOUND FOR: '+objField+ 'ID= '+currentMaxId+' MAX: '+currentMaxValue);
            //createInsight(currentMaxId, currentMaxValue, objField, currentParams);

            currentParams.put(idKeyName, currentMaxId);
            currentParams.put(valueKeyName, currentMaxValue);
        } else {
           // System.debug('LESS THAN ID: '+lastMaxId+' LAST VALUE: '+lastMaxValue + ' CURRENT: '+currentMaxValue);
        }
        return currentParams;
    }

}
