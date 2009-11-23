// this tests the configuration edit page's controller
@IsTest
private class ConfigurationEditControllerTest {

    static testMethod void testConstructorAndSave() {
        // setup the page and set it as the test's current page
        PageReference myPage = Page.ConfigurationEdit;
        Test.setCurrentPage(myPage);

        // first instantiate the configuration object and insert it
        Configuration__c conf = ConfigurationTestUtility.buildConfiguration('theName', 'MUWTestObject__c');
        insert conf;
        // create the custom extension based on that standard controller
        ConfigurationEditController cont = getController(conf);
        // set the type to something
        cont.setTheType(Constants.none);
        cont.save();
        // verify that the record's been updated by the save operation (but not to the DB)
        Configuration__c newConf = cont.getRecord();
        System.assertEquals(Constants.none, newConf.type__c);
        // query for that configuration
        newConf = [select id, name, type__c from configuration__c where id=:conf.id];
        System.assertEquals('MUWTestObject__c', newConf.type__c);
    }
    
    static testMethod void testGetterAndSetter() {
        // get the controller
        ConfigurationEditController cont = getController();
        // set the type
        cont.setTheType('blah');
        // assert that it's been set
        System.assertEquals('blah', cont.getTheType());
    }
    
    static testMethod void testGetSupportedTypes() {
        // get the controller
        ConfigurationEditController cont = getController();
        // get the supported types
        List<SelectOption> supportedTypes = cont.getSupportedTypes();
        // check that the list isn't null
        System.assert(supportedTypes != null);
        // check that the list has more than 1 option
        System.assert(supportedTypes.size() > 1);
    }
    
    // another util to get the controller
    private static ConfigurationEditController getController() {
        // instantiate a dummy configuration to use when creating the standard controller
        Configuration__c conf = new Configuration__c();
        // pass it to the controller
        return getController(conf);
    }
    
    // simple test utility to get the controller
    private static ConfigurationEditController getController(Configuration__c conf) {
        // create the standard controller for the passed in object
        ApexPages.StandardController stdCont = new ApexPages.StandardController(conf);
        // create the custom extension based on that standard controller
        ConfigurationEditController cont = new ConfigurationEditController(stdCont);
        // return it
        return cont;
    }

}