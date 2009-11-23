@IsTest
private class UpdateValueTriggerTest {
	
	static testMethod void testDuplicateFieldName() {
		// set up a configuration
        Configuration__c conf = ConfigurationTestUtility.buildConfiguration('conf', 'MUWTestObject__c');
        insert conf;
        
        // try to insert two update values that have the same name
        List<UpdateValue__c> uvs = new List<UpdateValue__c>();
        for(integer i=0; i<2; i++) {
        	uvs.add(UpdateValueTestUtility.buildUpdateValue('name', 'name', 'blah', conf.id));
        }
        try {
        	insert uvs;
        	// shouldn't get here
        	System.assert(false, 'exception should have been thrown!');
        } catch(System.DmlException e) {
        	System.assertEquals(1, e.getNumDml());
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
            System.assertEquals(Constants.updateValueDuplicateFieldNameErrorMessage, e.getDmlMessage(0));
        }
        
        // now insert one, then insert another to have the same name
        UpdateValue__c uv1 = UpdateValueTestUtility.buildUpdateValue('name', 'name', 'blah', conf.id);
        UpdateValue__c uv2 = UpdateValueTestUtility.buildUpdateValue('name', 'name', 'blah', conf.id);
        insert uv1;
        try {
            insert uv2;
            // shouldn't get here
            System.assert(false, 'exception should have been thrown!');
        } catch(System.DmlException e) {
            System.assertEquals(1, e.getNumDml());
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
            System.assertEquals(Constants.updateValueDuplicateFieldNameErrorMessage, e.getDmlMessage(0));
        }
        
        // now insert another valid one, then update it to have the same name as the other
        uv2 = UpdateValueTestUtility.buildUpdateValue('name2', 'name2', 'blah', conf.id);
        insert uv2;
        uv2.fieldname__c = 'name';
        try {
            update uv2;
            // shouldn't get here
            System.assert(false, 'exception should have been thrown!');
        } catch(System.DmlException e) {
            System.assertEquals(1, e.getNumDml());
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
            System.assertEquals(Constants.updateValueDuplicateFieldNameErrorMessage, e.getDmlMessage(0));
        }
	}
	
	static testMethod void testOneLessThanTooMany() {
        // set up a configuration
        Configuration__c conf = ConfigurationTestUtility.buildConfiguration('conf', 'MUWTestObject__c');
        insert conf;
        // set up another configuration
        Configuration__c conf2 = ConfigurationTestUtility.buildConfiguration('conf2', 'MUWTestObject__c');
        insert conf2;
        
        // insert 49 update values on both
        List<UpdateValue__c> uvs = new List<UpdateValue__c>();
        for(integer i=0; i<49; i++) {
            UpdateValue__c uv = UpdateValueTestUtility.buildUpdateValue('name' + i, 'name' + i, 'blah', conf.id);
            UpdateValue__c uv2 = UpdateValueTestUtility.buildUpdateValue('name' + i, 'name' + i, 'blah', conf2.id);
            uvs.add(uv);
            uvs.add(uv2);
        }
        insert uvs;
        
        // insert five more for the first one and only one more for the second
        uvs = new List<UpdateValue__c>();
        for(integer i=0; i<5; i++) {
            UpdateValue__c uv = UpdateValueTestUtility.buildUpdateValue('newname' + i, 'newname' + i, 'blah', conf.id);
            uvs.add(uv);
        }
        uvs.add(UpdateValueTestUtility.buildUpdateValue('newname2', 'newname2', 'blah', conf2.id));
        try {
            insert uvs;
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
        integer count = [select count() from UpdateValue__c where configuration__c=:conf2.id];
        System.assertEquals(49, count);
    }

    static testMethod void testTooMany() {
    	// set up a configuration
        Configuration__c conf = new Configuration__c();
        conf.name = 'tooManyTest';
        conf.type__c = 'MUWTestObject__c';
        insert conf;
        
        // insert 50 update values
        List<UpdateValue__c> uvs = new List<UpdateValue__c>();
        for(integer i=0; i<50; i++) {
            UpdateValue__c uv = UpdateValueTestUtility.buildUpdateValue('name' + i, 'name' + i, 'blah', conf.id);
            uvs.add(uv);
        }
        insert uvs;
        
        // insert one more, should fail
        UpdateValue__c uv = UpdateValueTestUtility.buildUpdateValue('newname', 'newname', 'blah', conf.id);
        try {
            insert uv;
            // shouldn't get here
            System.assert(false, 'exception should have been thrown!');
        } catch(System.DmlException e) {
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
            System.assertEquals(Constants.tooManyUpdateValuesErrorMessage, e.getDmlMessage(0));
        }
    }
    
    static testMethod void testFieldValidation() {
    	// set up a configuration
    	Configuration__c conf = ConfigurationTestUtility.buildConfiguration('conf', 'MUWTestObject__c');
    	insert conf;
    	
    	// set up an update value whose fieldname is none
        UpdateValue__c uv = UpdateValueTestUtility.buildUpdateValue('name', Constants.none, 'blah', conf.id);
        try {
        	insert uv;
        	// shouldn't get here
        	System.assert(false);
        } catch(System.DmlException e) {
        	System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
            System.assertEquals(Constants.updateValueIncorrectFieldNameErrorMessage, e.getDmlMessage(0));
        }    	
    }

}