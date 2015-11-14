public with sharing class DataBot {

	public static List <DataBotObjectFieldTuple> getTuplesForType(Schema.DisplayType displayType) {

		Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
		List <DataBotObjectFieldTuple> matchingTypes = new List <DataBotObjectFieldTuple> ();
		for (String key : gd.keySet()) {

		    SObjectType objType = gd.get(key);
		    String objectName = objType.getDescribe().getLabel();
		    //System.debug('NAME: '+objectName);

		    for (Schema.SObjectField field: objType.getDescribe().fields.getMap().values()){
		        Schema.DisplayType fieldType = field.getDescribe().getType();
		        if (fieldType == displayType) {
		            //System.debug('Object Name= '+objectName+' API Field Name =  '+field.getDescribe().getName()+' ---API Field Type= '+fieldType.name());

					DataBotObjectFieldTuple tuple = new DataBotObjectFieldTuple(objType, field);
					matchingTypes.add(tuple);
		        }
		    }
		}
		return matchingTypes;
	}

	public DataBot() {

	}
}