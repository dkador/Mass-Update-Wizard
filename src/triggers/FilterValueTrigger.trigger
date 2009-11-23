trigger FilterValueTrigger on FilterValue__c (before insert, before update, after undelete) {
	// keeps track of how many filter values per configuration have been deemed acceptable
	Map<String, Integer> filterValueCountPerConfiguration = new Map<String, Integer>();
	// iterate through all the objects
    for(FilterValue__c fv : Trigger.new) {
    	if(Constants.none.equals(fv.fieldname__c)) {
    		fv.addError(Constants.filterValueIncorrectFieldNameErrorMessage);
    	} 
    	if(Constants.none.equals(fv.operator__c)) {
    		fv.addError(Constants.filterValueIncorrectOperatorErrorMessage);
    	}
    	if(!'and'.equalsIgnoreCase(fv.logicaljoin__c) && !'or'.equalsIgnoreCase(fv.logicaljoin__c)) {
    		fv.addError(Constants.filterValueIncorrectLogicalJoinErrorMessage);
    	}
    	// if the trigger is on an insert or an undelete operation, verify that that operation
        // hasn't resulted in more than 50 filter values existing for the object
        if(Trigger.isInsert || Trigger.isUnDelete) {
        	// figure out how many filter values we've seen for this configuration
            Integer numberOfFilterValuesProcessed = filterValueCountPerConfiguration.get(fv.configuration__c);
            if(numberOfFilterValuesProcessed == null) {
                List<FilterValue__c> fvs = [select id from filtervalue__c where configuration__c=:fv.configuration__c];
                numberOfFilterValuesProcessed = fvs.size() + 1;
            } else {
                numberOfFilterValuesProcessed++;
            }
            // verify that the insert/undelete won't result in more than 50 values per configuration
            if(numberOfFilterValuesProcessed > 50) {
                fv.addError(Constants.tooManyFilterValuesErrorMessage);
            } else {
                filterValueCountPerConfiguration.put(fv.configuration__c, numberOfFilterValuesProcessed);
            }
        }
    }
}