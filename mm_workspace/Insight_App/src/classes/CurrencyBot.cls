public with sharing class CurrencyBot {

	public CurrencyBot() {

		System.debug('run the currency bot');

		// get all the SObjectTypes that have at least one Schema.DisplayType.Currency
		List <DataBotObjectFieldTuple> matchingTypes = DataBot.getTuplesForType(Schema.DisplayType.Currency);

		for (DataBotObjectFieldTuple tuple : matchingTypes) {

			String objectName = tuple.objType.getDescribe().getLabel();
			//Schema.DisplayType fieldType = tuple.field.getDescribe().getType();
            //String fieldName = fieldType.name();

			System.debug(objectName+' [] '+ tuple.field.getDescribe().getName());

		}


	}
}
