// tests the trigger on configuration
@IsTest
private class ConfigurationTriggerTest {

    // tests what happens when you create a configuration
    static testMethod void testCreate() {
    	// insert with type set to none
    	Configuration__c conf = new Configuration__c();
    	conf.type__c = Constants.none;
    	try {
    		insert conf;
    		// shouldn't reach here 
    		System.assert(false, 'exception should have been thrown!');
    	} catch(System.DmlException e) {
    		System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
    		System.assertEquals(Constants.noObjectTypeErrorMessage, e.getDmlMessage(0));
    	}
    	
    	// now insert with valid type
    	conf.type__c = 'MUWTestObject__c';
    	conf.name = 'blah';
    	insert conf;
    	integer recordCount = [select count() from configuration__c where name='blah'];
    	System.assertEquals(1, recordCount); 
    }
    
    // tests what happens you update an existing configuration
    static testMethod void testUpdate() {
    	// set up a configuration, insert it, and then update it
    	Configuration__c conf = new Configuration__c();
    	conf.name = 'dododo';
    	conf.type__c = 'MUWTestObject__c';
    	insert conf;
    	conf.name = 'bobobo';
    	update conf;
    	System.assertEquals('bobobo', [select name from configuration__c where id=:conf.id].name);
    	
    	// insert some filter values and update values, then update the existing
    	// configuration to change the type.  those values should be deleted.
    	List<FilterValue__c> fvs = new List<FilterValue__c>();
    	List<UpdateValue__c> uvs = new List<UpdateValue__c>();
    	for(integer i=0; i<3; i++) {
    		FilterValue__c fv = FilterValueTestUtility.buildFilterValue('fv' + i, 'name', '=', 'blah', conf.id);
    		fvs.add(fv);
    		UpdateValue__c uv = UpdateValueTestUtility.buildUpdateValue('uv' + i, 'uv' + i, 'blah', conf.id);
    		uvs.add(uv);
    	}
    	insert fvs;
    	insert uvs;
    	// now change conf's type and update
    	conf.type__c = 'FilterValue__c';
    	update conf;
    	// verify deletions occurred
    	System.assertEquals(0, [select count() from filtervalue__c where configuration__c=:conf.id]);
    	System.assertEquals(0, [select count() from updatevalue__c where configuration__c=:conf.id]);
    }
    
    // tests that the trigger handles bulk operators ok
    static testMethod void testBulk() {
    	List<Configuration__c> confs = new List<Configuration__c>();
    	for(integer i=0; i<3; i++) {
    	   Configuration__c conf = new Configuration__c();
    	   conf.name = 'name' + i;
    	   conf.type__c = 'MUWTestObject__c';
    	   confs.add(conf);	
    	}
    	insert confs;
    	System.assertEquals(3, [select count() from configuration__c where name like 'name%']);
    }
    
    // tests that you can't save a configuration with an invalid type through the api or apex
    static testMethod void testTypeValidation() {
    	// try a not real type
    	Configuration__c conf = ConfigurationTestUtility.buildConfiguration('typeValidation', 'notreal');
    	try {
    		insert conf;
    		// shouldn't get here
    		System.assert(false);
    	} catch(System.DmlException e) {
    		System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
            System.assertEquals(Constants.invalidObjectTypeErrorMessage, e.getDmlMessage(0));
    	}
    	
    	// now try a real type that's not updateable
    	conf = ConfigurationTestUtility.buildConfiguration('typeValidation', 'CaseStatus');
        try {
            insert conf;
            // shouldn't get here
            System.assert(false);
        } catch(System.DmlException e) {
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
            System.assertEquals(Constants.invalidObjectTypeErrorMessage, e.getDmlMessage(0));
        }
    }

}