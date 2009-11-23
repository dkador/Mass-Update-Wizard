trigger ConfigurationTrigger on Configuration__c (before insert, before update) {
    // get all the valid types for configuration (this only really matters for the api)
    // but we should double-check all the same
    Map<String, Schema.SObjectType> typeMap = Schema.getGlobalDescribe();
    for(integer i=0; i<Trigger.new.size(); i++) {
        Configuration__c newC = Trigger.new[i];
        if(Constants.none.equals(newC.type__c)) {
            newC.addError(Constants.noObjectTypeErrorMessage);
            continue;
        }
        // check that the type is a supported, updateable type
        if(typeMap.containsKey(newC.type__c)) {
            Schema.DescribeSObjectResult describeResult = typeMap.get(newC.type__c).getDescribe();
            System.debug(describeResult.getName() + ': ' + describeResult.isUpdateable());
            if(!describeResult.isUpdateable()) {
                newC.addError(Constants.invalidObjectTypeErrorMessage);
                continue;
            }
        } else {
            newC.addError(Constants.invalidObjectTypeErrorMessage);
            continue;
        }
        if(Trigger.isUpdate) {
            Configuration__c oldC = Trigger.old[i];
            if(newC.type__c != null && oldC.type__c != null) {
                if(!newC.type__c.equals(oldC.type__c)) {
                    // find all the filter values and update values for this config
                    // then delete them
                    List<FilterValue__c> fvs = [select id from filtervalue__c where configuration__c=:newC.id];
                    delete fvs;
                    List<UpdateValue__c> uvs = [select id from updatevalue__c where configuration__c=:newC.id];
                    delete uvs;
                }
            }
        }
    }
}