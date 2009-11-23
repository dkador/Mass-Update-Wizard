trigger SelectValueTrigger on SelectValue__c (after undelete, before insert, before update) {
    // keeps track of how many select values per configuration have been deemed acceptable
    Map<String, Integer> selectValueCountPerConfiguration = new Map<String, Integer>();
    // iterate through all the objects
    for(SelectValue__c sv : Trigger.new) {
        if(Constants.none.equals(sv.fieldname__c)) {
            sv.addError(Constants.filterValueIncorrectFieldNameErrorMessage);
        } 
        // if the trigger is on an insert or an undelete operation, verify that that operation
        // hasn't resulted in more than 50 select values existing for the object
        if(Trigger.isInsert || Trigger.isUnDelete) {
            // figure out how many filter values we've seen for this configuration
            Integer numberOfSelectValuesProcessed = selectValueCountPerConfiguration.get(sv.configuration__c);
            if(numberOfSelectValuesProcessed == null) {
                List<SelectValue__c> svs = [select id from SelectValue__c where configuration__c=:sv.configuration__c];
                numberOfSelectValuesProcessed = svs.size() + 1;
            } else {
                numberOfSelectValuesProcessed++;
            }
            // verify that the insert/undelete won't result in more than 50 values per configuration
            if(numberOfSelectValuesProcessed > 50) {
                sv.addError(Constants.tooManyFilterValuesErrorMessage);
            } else {
                selectValueCountPerConfiguration.put(sv.configuration__c, numberOfSelectValuesProcessed);
            }
        }
    }
}