trigger UpdateValueTrigger on UpdateValue__c (after undelete, before insert, before update) {
    // keeps track of how many update values per configuration have been deemed acceptable
    Map<String, Integer> updateValueCountPerConfiguration = new Map<String, Integer>();
    // keeps track of all the field names that exist in each update value per configuration
    Map<String, Set<String>> fieldNamesPerConfiguration = new Map<String, Set<String>>();
    for(UpdateValue__c uv : Trigger.new) {
        // check that fieldname isn't none
        if(Constants.none.equals(uv.fieldname__c)) {
            uv.addError(Constants.updateValueIncorrectFieldNameErrorMessage);
        } 
        // check that the operation doesn't result in two updatevalues on the same configuration
        // having identical fieldnames
        Set<String> fieldNames = fieldNamesPerConfiguration.get(uv.configuration__c);
        if(fieldNames == null) {
            fieldNames = new Set<String>();
            for(UpdateValue__c existingUv : [select fieldname__c from updatevalue__c where configuration__c=:uv.configuration__c]) {
                fieldNames.add(existingUv.fieldname__c.toLowerCase());
            }
        }
        // verify that the chosen fieldname isn't an existing one
        if(fieldNames.contains(uv.fieldname__c.toLowerCase())) {
            uv.addError(Constants.updateValueDuplicateFieldNameErrorMessage);
        } else {
            fieldNames.add(uv.fieldname__c.toLowerCase());
        }
        fieldNamesPerConfiguration.put(uv.configuration__c, fieldNames);
        // if the trigger is on an insert or an undelete operation, verify that that operation
        // hasn't resulted in more than 50 update values existing for the object
        if(Trigger.isInsert || Trigger.isUnDelete) {
            // figure out how many update values we've seen for this configuration
            Integer numberOfUpdateValuesProcessed = updateValueCountPerConfiguration.get(uv.configuration__c);
            if(numberOfUpdateValuesProcessed == null) {
                List<UpdateValue__c> uvs = [select id from updatevalue__c where configuration__c=:uv.configuration__c];
                numberOfUpdateValuesProcessed = uvs.size() + 1;
            } else {
                numberOfUpdateValuesProcessed++;
            }
            // verify that the insert/undelete won't result in more than 50 values per configuration
            if(numberOfUpdateValuesProcessed > 50) {
                uv.addError(Constants.tooManyFilterValuesErrorMessage);
            } else {
                updateValueCountPerConfiguration.put(uv.configuration__c, numberOfUpdateValuesProcessed);
            }
        }
    }
}