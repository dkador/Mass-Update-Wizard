// this tests the controller for the main mass update wizard page
@IsTest
private class ControllerTest {

    // tests the doNothing action
    static testMethod void testDoNothing() {
    	// set the test's current page to the wizard
        PageReference myRef = Page.MassUpdateWizard;
        Test.setCurrentPage(myRef);
        
        // construct the controller
        MassUpdateWizardController cont = new MassUpdateWizardController();
        // do nothing
        PageReference nextPage = cont.doNothing();
        // assert that the returned page reference is null
        System.assert(nextPage == null);
    }
    
    // tests the findAffectedRecords action
    static testMethod void testFindAffectedRecords() {
    	// set the test's current page to the wizard
        PageReference myRef = Page.MassUpdateWizard;
        Test.setCurrentPage(myRef);
        
        // construct the controller
        MassUpdateWizardController cont = new MassUpdateWizardController();
        
        // initialize all the fields
        setFieldsToNone(cont);
        
        // don't do anything and do findAffectedRecords()
        PageReference nextPage = cont.findAffectedRecords();
        // should return null
        System.assertEquals(null, nextPage);
        // error message should be appropriate
        System.assertEquals(Constants.noObjectTypeErrorMessage, cont.getUpdateMessage());
        
        // now setup an invalid filter value (no operator) to test handling the thrown exception
        cont.setSelectedType('MUWTestObject__c');
        setFieldsToNone(cont);
        cont.setFilteredField1('Name');
        cont.setComparisonValue1('mwaaaaaa');
        cont.findAffectedRecords();
        System.assertEquals('There was a problem executing the action with your specified selections! The error is: The filter criteria\'s operator must be specified!', cont.getUpdateMessage());
        
        // now setup a real filter value that doesn't match anything
        cont.setSelectedOperator1('=');
        cont.findAffectedRecords();
        System.assertEquals(Constants.noValuesUpdatedMessage, cont.getRecordCountMessage());
        System.assertEquals('', cont.getUpdateMessage());
        
        // now setup a filter value that does match something (first create the record)
        MUWTestObject__c a = new MUWTestObject__c(name='testAcc');
        insert a;
        cont.setFilteredField1('Id');
        cont.setComparisonValue1(a.id);
        
        // find records without choosing fields to display back 
        cont.findAffectedRecords();
        System.assert(cont.getRecordCountMessage() != null);
        System.assertEquals('Found 1 matching record(s)!', cont.getRecordCountMessage());
        System.assertEquals('', cont.getUpdateMessage());
        // verify that we would now show the update button
        System.assert(cont.getShowUpdateButton());
        
        // find records with choosing fields to display back
        cont.setQueriedField1('Name');
        cont.setQueriedField2('Name');
        cont.setQueriedField3('Name');
        cont.setQueriedField4('Name');
        cont.setQueriedField5('Name');
        cont.findAffectedRecords();
        System.assert(cont.getRecordCountMessage() != null);
        System.assert(cont.getRecordCountMessage().contains('<table'), 'record count message does not contain "<table"! it is: '
            + cont.getRecordCountMessage());
        System.assertEquals('', cont.getUpdateMessage());
        // verify that we would now show the update button
        System.assert(cont.getShowUpdateButton());
    }
    
    // tests the updateRecords action
    static testMethod void testUpdateRecords() {
    	// set the test's current page to the wizard
        PageReference myRef = Page.MassUpdateWizard;
        Test.setCurrentPage(myRef);
        
        // construct the controller
        MassUpdateWizardController cont = new MassUpdateWizardController();
        
        // don't select a type and do updateRecords()
        PageReference nextPage = cont.updateRecords();
        // should return null
        System.assertEquals(null, nextPage);
        // error message should be appropriate
        System.assertEquals(Constants.noObjectTypeErrorMessage, cont.getUpdateMessage());
        
        // now select a type but don't select a field to filter on
        cont.setSelectedType('MUWTestObject__c');
        setFieldsToNone(cont);
        cont.updateRecords();
        // error message should be appropriate
        System.assertEquals(Constants.noFiltersErrorMessage, cont.getUpdateMessage());
        
        // insert a test object to filter on 
        MUWTestObject__c a = new MUWTestObject__c(name='testAcc');
        insert a;
        // filter on that id
        cont.setFilteredField1('Id');
        cont.setSelectedOperator1('=');
        cont.setComparisonValue1(a.id);
        // don't set an update value
        cont.updateRecords();
        // error message should be appropriate
        System.assertEquals(Constants.noUpdateValuesErrorMessage, cont.getUpdateMessage());
        
        // specify fields to update
        cont.setUpdateField1('Name');
        String newValue = 'I AM A NEW VALUE DUH';
        cont.setUpdateValue1(newValue);
        // do the update
        cont.updateRecords();
        // find the record, make sure it was updated
        a = [select id, name from MUWTestObject__c where id=:a.id];
        System.assertEquals(newValue, a.name);
        // make sure the appropriate message is surfaced to the user
        System.assertEquals(Constants.getSuccessfulUpdateMessage(1), cont.getUpdateMessage());
        
        // now do an update where no matching records are found
        cont.setFilteredField1('Name');
        cont.setSelectedOperator1('=');
        cont.setComparisonValue1('im not real you dummy');
        cont.updateRecords();
        System.assertEquals(Constants.noValuesUpdatedMessage, cont.getUpdateMessage());
        
        // now do an update with an invalid update value (field name not specified)
        cont.setUpdateField1(Constants.none);
        cont.updateRecords();
        System.assertEquals('There was a problem executing the action with your specified selections! The error is: The update value\'s field name must be specified!', cont.getUpdateMessage());
    }
    
    // internal function to set all fields to none or empty (this sets up the wizard 
    // like it's setup when the user loads the page)
    private static void setFieldsToNone(MassUpdateWizardController cont) {
        cont.setFilteredField1(Constants.none);
        cont.setFilteredField2(Constants.none);
        cont.setFilteredField3(Constants.none);
        cont.setFilteredField4(Constants.none);
        cont.setFilteredField5(Constants.none);
        
        cont.setSelectedOperator1(Constants.none);
        cont.setSelectedOperator2(Constants.none);
        cont.setSelectedOperator3(Constants.none);
        cont.setSelectedOperator4(Constants.none);
        cont.setSelectedOperator5(Constants.none);
        
        cont.setComparisonValue1('');
        cont.setComparisonValue2('');
        cont.setComparisonValue3('');
        cont.setComparisonValue4('');
        cont.setComparisonValue5('');
        
        cont.setQueriedField1(Constants.none);
        cont.setQueriedField2(Constants.none);
        cont.setQueriedField3(Constants.none);
        cont.setQueriedField4(Constants.none);
        cont.setQueriedField5(Constants.none);
        
        cont.setUpdateField1(Constants.none);
        cont.setUpdateField2(Constants.none);
        cont.setUpdateField3(Constants.none);
        cont.setUpdateField4(Constants.none);
        cont.setUpdateField5(Constants.none);
        
        cont.setUpdateValue1('');
        cont.setUpdateValue2('');
        cont.setUpdateValue3('');
        cont.setUpdateValue4('');
        cont.setUpdateValue5('');
    }
    
    // tests the selected type variable
    static testMethod void testSelectedType() {
        MassUpdateWizardController cont = new MassUpdateWizardController();
        cont.setSelectedType('MUWTestObject__c');
        System.assertEquals('MUWTestObject__c', cont.getSelectedType());
    }
    
    // tests the selected options variable
    static testMethod void testSelectedOptions() {
        MassUpdateWizardController cont = new MassUpdateWizardController();
        String[] options = new String[] { 'a', 'b', 'c' };
        cont.setSelectedOptions(options);
        System.assertEquals(options, cont.getSelectedOptions());
        // make sure to test the case when the option matches        
        System.assert(OptionsUtility.getShowLabels(new String[] { Constants.showLabels }));
    }
    
    // tests the filtered fields variables
    static testMethod void testFilteredFields() {
        MassUpdateWizardController cont = new MassUpdateWizardController();
        cont.setFilteredField1('a');
        cont.setFilteredField2('b');
        cont.setFilteredField3('c');
        cont.setFilteredField4('d');
        cont.setFilteredField5('e');
        System.assertEquals('a', cont.getFilteredField1());
        System.assertEquals('b', cont.getFilteredField2());
        System.assertEquals('c', cont.getFilteredField3());
        System.assertEquals('d', cont.getFilteredField4());
        System.assertEquals('e', cont.getFilteredField5());
    }
    
    // tests the selected operators variables
    static testMethod void testSelectedOperators() {
        MassUpdateWizardController cont = new MassUpdateWizardController();
        cont.setSelectedOperator1('a');
        cont.setSelectedOperator2('b');
        cont.setSelectedOperator3('c');
        cont.setSelectedOperator4('d');
        cont.setSelectedOperator5('e');
        System.assertEquals('a', cont.getSelectedOperator1());
        System.assertEquals('b', cont.getSelectedOperator2());
        System.assertEquals('c', cont.getSelectedOperator3());
        System.assertEquals('d', cont.getSelectedOperator4());
        System.assertEquals('e', cont.getSelectedOperator5());
    }
    
    // tests the comparison values variables
    static testMethod void testComparisonValues() {
        MassUpdateWizardController cont = new MassUpdateWizardController();
        cont.setComparisonValue1('a');
        cont.setComparisonValue2('b');
        cont.setComparisonValue3('c');
        cont.setComparisonValue4('d');
        cont.setComparisonValue5('e');
        System.assertEquals('a', cont.getComparisonValue1());
        System.assertEquals('b', cont.getComparisonValue2());
        System.assertEquals('c', cont.getComparisonValue3());
        System.assertEquals('d', cont.getComparisonValue4());
        System.assertEquals('e', cont.getComparisonValue5());
    }
    
    // tests the queriedField variables
    static testMethod void testQueriedFields() {
        MassUpdateWizardController cont = new MassUpdateWizardController();
        cont.setQueriedField1('a');
        cont.setQueriedField2('b');
        cont.setQueriedField3('c');
        cont.setQueriedField4('d');
        cont.setQueriedField5('e');
        System.assertEquals('a', cont.getQueriedField1());
        System.assertEquals('b', cont.getQueriedField2());
        System.assertEquals('c', cont.getQueriedField3());
        System.assertEquals('d', cont.getQueriedField4());
        System.assertEquals('e', cont.getQueriedField5());
    }
    
    // tests the update fields variables
    static testMethod void testUpdateFields() {
        MassUpdateWizardController cont = new MassUpdateWizardController();
        cont.setUpdateField1('a');
        cont.setUpdateField2('b');
        cont.setUpdateField3('c');
        cont.setUpdateField4('d');
        cont.setUpdateField5('e');
        System.assertEquals('a', cont.getUpdateField1());
        System.assertEquals('b', cont.getUpdateField2());
        System.assertEquals('c', cont.getUpdateField3());
        System.assertEquals('d', cont.getUpdateField4());
        System.assertEquals('e', cont.getUpdateField5());
    }
    
    // tests the update values variables
    static testMethod void testUpdateValues() {
        MassUpdateWizardController cont = new MassUpdateWizardController();
        cont.setUpdateValue1('a');
        cont.setUpdateValue2('b');
        cont.setUpdateValue3('c');
        cont.setUpdateValue4('d');
        cont.setUpdateValue5('e');
        System.assertEquals('a', cont.getUpdateValue1());
        System.assertEquals('b', cont.getUpdateValue2());
        System.assertEquals('c', cont.getUpdateValue3());
        System.assertEquals('d', cont.getUpdateValue4());
        System.assertEquals('e', cont.getUpdateValue5());
    }
    
    // tests the logical joins variables
    static testMethod void testLogicalJoins() {
    	MassUpdateWizardController cont = new MassUpdateWizardController();
    	cont.setLogicalJoin1('a');
    	cont.setLogicalJoin2('b');
    	cont.setLogicalJoin3('c');
    	cont.setLogicalJoin4('d');
    	System.assertEquals('a', cont.getLogicalJoin1());
    	System.assertEquals('b', cont.getLogicalJoin2());
    	System.assertEquals('c', cont.getLogicalJoin3());
    	System.assertEquals('d', cont.getLogicalJoin4());
    }

    // tests that the select options for the sobject types field are generated correctly
    static testMethod void testGetTypes() {
        MassUpdateWizardController cont = new MassUpdateWizardController();
        List<SelectOption> options = cont.getTypes();
        System.assert(options != null);
        System.assert(options.size() > 0);
    }
    
    // tests that the select options for the configurations are generated correctly
    static testMethod void testGetConfigurationOptions() {
        MassUpdateWizardController cont = new MassUpdateWizardController();
        List<SelectOption> options = cont.getConfigurationOptions();
        System.assert(options != null); 
        System.assert(options.size() > 0);
    }

    // tests that the select options for the filterable fields are generated correctly    
    static testMethod void testGetFilterableFields() {
        MassUpdateWizardController cont = new MassUpdateWizardController();
        cont.setSelectedType('MUWTestObject__c');
        List<SelectOption> options = cont.getFilterableFields();
        System.assert(options != null); 
        System.assert(options.size() > 1);
        // test when 'include parent fields' is on
        cont.setSelectedOptions(new String[] { Constants.showParentFields} );
        List<SelectOption> optionsWithParents = cont.getFilterableFields();
        System.assert(optionsWithParents.size() > options.size(), 'optionsWithParents (' + optionsWithParents.size() + ') was not greater than options (' + options.size() + ')');
    }
    
    // tests that the select options for the queryable fields are generated correctly
    static testMethod void testGetQueryableFields() {
        MassUpdateWizardController cont = new MassUpdateWizardController();
        cont.setSelectedType('MUWTestObject__c');
        List<SelectOption> options = cont.getQueryableFields();
    	System.assert(options != null);
    	System.assert(options.size() > 1);
    	// test when 'include parent fields' is on
    	cont.setSelectedOptions(new String[] { Constants.showParentFields} );
    	List<SelectOption> optionsWithParents = cont.getQueryableFields();
        System.assert(optionsWithParents.size() > options.size(), 'optionsWithParents (' + optionsWithParents.size() + ') was not greater than options (' + options.size() + ')');
    }
    
    // tests that the select options for the updateable fields are generated correctly
    static testMethod void testGetUpdateableFields() {
        MassUpdateWizardController cont = new MassUpdateWizardController();
        List<SelectOption> options = cont.getUpdateableFields();
        System.assert(options != null); 
        System.assert(options.size() > 0);
    }
    
    // tests that the select options for the operators are generated correctly
    static testMethod void testGetOperators() {
        MassUpdateWizardController cont = new MassUpdateWizardController();
        List<SelectOption> options = cont.getOperators1();
        System.assert(options != null); 
        System.assert(options.size() > 0);
        options = cont.getOperators2();
        System.assert(options != null); 
        System.assert(options.size() > 0);
        options = cont.getOperators3();
        System.assert(options != null); 
        System.assert(options.size() > 0);
        options = cont.getOperators4();
        System.assert(options != null); 
        System.assert(options.size() > 0);
        options = cont.getOperators5();
        System.assert(options != null); 
        System.assert(options.size() > 0);
    }
    
    // tests that the select options for the logical joins are generated correctly
    static testMethod void testGetLogicalJoins() {
        MassUpdateWizardController cont = new MassUpdateWizardController();
        List<SelectOption> options = cont.getLogicalJoins();
        System.assert(options != null); 
        System.assertEquals(2, options.size());
    }    
    
}