@IsTest
private class SelectValueTriggerTest {

    static testMethod void testOneLessThanTooMany() {
        // set up a configuration
        Configuration__c conf = ConfigurationTestUtility.buildConfiguration('conf', 'MUWTestObject__c');
        insert conf;
        // set up another configuration
        Configuration__c conf2 = ConfigurationTestUtility.buildConfiguration('conf2', 'MUWTestObject__c');
        insert conf2;
        
        // insert 49 select values on both
        List<SelectValue__c> svs = new List<SelectValue__c>();
        for(integer i=0; i<49; i++) {
            SelectValue__c sv = SelectValueTestUtility.buildSelectValue('name' + i, 'name', conf.id);
            SelectValue__c sv2 = SelectValueTestUtility.buildSelectValue('name' + i, 'name', conf2.id);
            svs.add(sv);
            svs.add(sv2);
        }
        insert svs;
        
        // insert five more for the first one and only one more for the second
        svs = new List<SelectValue__c>();
        for(integer i=0; i<5; i++) {
            SelectValue__c sv = SelectValueTestUtility.buildSelectValue('newname', 'name', conf.id);
            svs.add(sv);
        }
        svs.add(SelectValueTestUtility.buildSelectValue('newname2', 'name', conf2.id));
        try {
            insert svs;
            // shouldn't get here
            System.assert(false, 'exception should have been thrown!');
        } catch(System.DmlException e) {
            for(integer i=0; i<e.getNumDml(); i++) {
                System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(i));
                System.assertEquals(Constants.tooManyFilterValuesErrorMessage, e.getDmlMessage(i));
            }
        }
        // verify that the select value added to the second configuration is rolled back even though
        // it was fine.
        integer count = [select count() from SelectValue__c where configuration__c=:conf2.id];
        System.assertEquals(49, count);
    }

    static testMethod void testTooMany() {
        // set up a configuration
        Configuration__c conf = new Configuration__c();
        conf.name = 'tooManyTest';
        conf.type__c = 'MUWTestObject__c';
        insert conf;
        
        // insert 50 filter values
        List<SelectValue__c> svs = new List<SelectValue__c>();
        for(integer i=0; i<50; i++) {
            SelectValue__c sv = SelectValueTestUtility.buildSelectValue('name' + i, 'name', conf.id);
            svs.add(sv);
        }
        insert svs;
        
        // insert one more, should fail
        SelectValue__c sv = SelectValueTestUtility.buildSelectValue('newname', 'name', conf.id);
        try {
            insert sv;
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
        SelectValue__c sv = SelectValueTestUtility.buildSelectValue('nofieldname', Constants.none, conf.id);
        try {
            insert sv;
            // shouldn't get here
            System.assert(false, 'exception should have been thrown');
        } catch(System.DmlException e) {
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
            System.assertEquals(Constants.filterValueIncorrectFieldNameErrorMessage, e.getDmlMessage(0));
        }
    }

}