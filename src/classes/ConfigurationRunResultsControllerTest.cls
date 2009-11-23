// this has the tests for the configuration run results controller
@IsTest
private class ConfigurationRunResultsControllerTest {
	
	static testMethod void testNoFilterValues() {
		// set the test's current page to the run results page
        PageReference myPage = Page.ConfigurationRunResults;
        Test.setCurrentPage(myPage);
            
        // build the configuration object and insert it
        Configuration__c conf = ConfigurationTestUtility.buildConfiguration();
        insert conf;
        // instantiate the standard controller based on the configuration
        ApexPages.StandardController stdCont = new ApexPages.StandardController(conf);
        // instantiate the custom controller extension based on the standard controller
        ConfigurationRunResultsController cont = new ConfigurationRunResultsController(stdCont);
        
        // verify the update message when no filter values are added
        System.assertEquals(Constants.runResultsNoFilterValuesErrorMessage, cont.getUpdateMessage());
	}
	
	static testMethod void testNoUpdateValues() {
		// set the test's current page to the run results page
        PageReference myPage = Page.ConfigurationRunResults;
        Test.setCurrentPage(myPage);
            
        // build the configuration object and insert it
        Configuration__c conf = ConfigurationTestUtility.buildConfiguration();
        insert conf;
        // instantiate the standard controller based on the configuration
        ApexPages.StandardController stdCont = new ApexPages.StandardController(conf);
        // instantiate the custom controller extension based on the standard controller
        ConfigurationRunResultsController cont = new ConfigurationRunResultsController(stdCont);
        
        // build and insert a filter value for the configuration
        FilterValue__c fv = FilterValueTestUtility.buildFilterValue('fv1', 'name', '=', 'barf', conf.id);
        insert fv;
        // verify the update message when no update values are added
        cont.doUpdate();
        System.assertEquals(Constants.runResultsNoUpdateValuesErrorMessage, cont.getUpdateMessage());
	}
	
	static testMethod void testNoMatchingRecordsUpdated() {
		// set the test's current page to the run results page
        PageReference myPage = Page.ConfigurationRunResults;
        Test.setCurrentPage(myPage);
            
        // build the configuration object and insert it
        Configuration__c conf = ConfigurationTestUtility.buildConfiguration();
        insert conf;
        
        // build and insert a filter value for the configuration
        FilterValue__c fv = FilterValueTestUtility.buildFilterValue('fv1', 'name', '=', 'barf', conf.id);
        insert fv;
        
        // instantiate the standard controller based on the configuration
        ApexPages.StandardController stdCont = new ApexPages.StandardController(conf);
        // instantiate the custom controller extension based on the standard controller
        ConfigurationRunResultsController cont = new ConfigurationRunResultsController(stdCont);
        
        // now add an update value and check that no records are updated when the filter criteria
        // match no records
        UpdateValue__c uv = UpdateValueTestUtility.buildUpdateValue('uv1', 'name', 'newbarf', conf.id);
        insert uv;
        cont.doUpdate();
        System.assertEquals(Constants.noValuesUpdatedMessage, cont.getUpdateMessage());
	}
	
	// let's test the main method
	static testMethod void testMatchingRecordsUpdated() {
		// set the test's current page to the run results page
        PageReference myPage = Page.ConfigurationRunResults;
        Test.setCurrentPage(myPage);
        
        // build the configuration object and insert it
        Configuration__c conf = ConfigurationTestUtility.buildConfiguration();
        insert conf;
        
        // build and insert a filter value for the configuration
        FilterValue__c fv = FilterValueTestUtility.buildFilterValue('fv1', 'name', '=', 'barf', conf.id);
        insert fv;
        
        // now add an update value and check that no records are updated when the filter criteria
        // match no records
        UpdateValue__c uv = UpdateValueTestUtility.buildUpdateValue('uv1', 'name', 'newbarf', conf.id);
        insert uv;
        
        // now add a matching test object
        MUWTestObject__c a = new MUWTestObject__c(name='barf');
        insert a;
        
        // instantiate the standard controller based on the configuration
        ApexPages.StandardController stdCont = new ApexPages.StandardController(conf);
        // instantiate the custom controller extension based on the standard controller
        ConfigurationRunResultsController cont = new ConfigurationRunResultsController(stdCont);
        
        // verify that it found the one test object
        System.assertEquals('Found 1 matching record(s)!', cont.getRecordCountMessage());
        
        // do the update
        cont.doUpdate();
        // verify that the page's update message is correct
        System.assertEquals(Constants.getSuccessfulUpdateMessage(1), cont.getUpdateMessage());
        // verify that the record was actually updated
        MUWTestObject__c newA = [select name from MUWTestObject__c where id=:a.id];
        System.assertEquals('newbarf', newA.name);
	}

}