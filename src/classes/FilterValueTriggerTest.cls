@IsTest
private class FilterValueTriggerTest {
	
	static testMethod void testOneLessThanTooMany() {
		// set up a configuration
        Configuration__c conf = ConfigurationTestUtility.buildConfiguration('conf', 'MUWTestObject__c');
        insert conf;
        // set up another configuration
        Configuration__c conf2 = ConfigurationTestUtility.buildConfiguration('conf2', 'MUWTestObject__c');
        insert conf2;
        
        // insert 49 filter values on both
        List<FilterValue__c> fvs = new List<FilterValue__c>();
        for(integer i=0; i<49; i++) {
            FilterValue__c fv = FilterValueTestUtility.buildFilterValue('name' + i, 'name', '=', 'blah', conf.id);
            FilterValue__c fv2 = FilterValueTestUtility.buildFilterValue('name' + i, 'name', '=', 'blah', conf2.id);
            fvs.add(fv);
            fvs.add(fv2);
        }
        insert fvs;
        
        // insert five more for the first one and only one more for the second
        fvs = new List<FilterValue__c>();
        for(integer i=0; i<5; i++) {
            FilterValue__c fv = FilterValueTestUtility.buildFilterValue('newname', 'name', '=', 'blah', conf.id);
            fvs.add(fv);
        }
        fvs.add(FilterValueTestUtility.buildFilterValue('newname2', 'name', '=', 'blah', conf2.id));
        try {
            insert fvs;
            // shouldn't get here
            System.assert(false, 'exception should have been thrown!');
        } catch(System.DmlException e) {
        	for(integer i=0; i<e.getNumDml(); i++) {
                System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(i));
                System.assertEquals(Constants.tooManyFilterValuesErrorMessage, e.getDmlMessage(i));
        	}
        }
        // verify that the filter value added to the second configuration is rolled back even though
        // it was fine.
        integer count = [select count() from filtervalue__c where configuration__c=:conf2.id];
        System.assertEquals(49, count);
	}

    static testMethod void testTooMany() {
    	// set up a configuration
    	Configuration__c conf = new Configuration__c();
    	conf.name = 'tooManyTest';
    	conf.type__c = 'MUWTestObject__c';
    	insert conf;
    	
    	// insert 50 filter values
    	List<FilterValue__c> fvs = new List<FilterValue__c>();
    	for(integer i=0; i<50; i++) {
    		FilterValue__c fv = FilterValueTestUtility.buildFilterValue('name' + i, 'name', '=', 'blah', conf.id);
    		fvs.add(fv);
    	}
    	insert fvs;
    	
    	// insert one more, should fail
    	FilterValue__c fv = FilterValueTestUtility.buildFilterValue('newname', 'name', '=', 'blah', conf.id);
    	try {
    		insert fv;
    		// shouldn't get here
    		System.assert(false, 'exception should have been thrown!');
    	} catch(System.DmlException e) {
    		System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
            System.assertEquals(Constants.tooManyFilterValuesErrorMessage, e.getDmlMessage(0));
    	}
    }
    
    static testMethod void testFieldValidations() {
        // set up a configuration
        Configuration__c conf = new Configuration__c();
        conf.name = 'testFieldValidations';
        conf.type__c = 'MUWTestObject__c';
        insert conf;
        
        // set fieldname to --none--
        FilterValue__c fv = FilterValueTestUtility.buildFilterValue('nofieldname', Constants.none, '=', 'blah', conf.id);
        try {
        	insert fv;
        	// shouldn't get here
        	System.assert(false, 'exception should have been thrown');
        } catch(System.DmlException e) {
        	System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
            System.assertEquals(Constants.filterValueIncorrectFieldNameErrorMessage, e.getDmlMessage(0));
        }
        
        // set operator to --none--
        fv = FilterValueTestUtility.buildFilterValue('nooperatorname', 'name', Constants.none, 'blah', conf.id);
        try {
            insert fv;
            // shouldn't get here
            System.assert(false, 'exception should have been thrown');
        } catch(System.DmlException e) {
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
            System.assertEquals(Constants.filterValueIncorrectOperatorErrorMessage, e.getDmlMessage(0));
        }
        
        // set logical join to something other than 'and' or 'or'
        fv = FilterValueTestUtility.buildFilterValue('dodo', 'name', '=', 'blah', 'NOTANDOROR', conf.id);
        try {
            insert fv;
            // shouldn't get here
            System.assert(false, 'exception should have been thrown');
        } catch(System.DmlException e) {
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
            System.assertEquals(Constants.filterValueIncorrectLogicalJoinErrorMessage, e.getDmlMessage(0));
        }
    }

}