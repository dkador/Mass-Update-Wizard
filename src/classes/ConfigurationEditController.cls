// this is the controller for the configuration edit page
public class ConfigurationEditController {

    // this keeps track of the standard controller that the custom controller
    // extensions use
    private ApexPages.StandardController stdController;
    // this stores the value of the selected sobject type
    private String theType;

    // this constructor takes in a StandardController since this controller is a
    // custom extension
    public ConfigurationEditController(ApexPages.StandardController stdController) {
        this.stdController = stdController;
        // this has to be a list because the query will either return 0 records or 1 record
        // it returns 0 if the user is creating a new object, 1 if editing an existing one
        List<Configuration__c> c = [select id, type__c from configuration__c where id=:stdController.getId()];
        // set the type so we can populate the page if editing an existing record
        if(c.size() == 1) {
           this.theType = c[0].type__c;
        }
    }
    
    // saves the configuration to the DB
    public PageReference save() {
        Configuration__c newC = (Configuration__c)stdController.getRecord();
        newC.type__c = theType;
        return stdController.save();
    }
    
    public String getTheType() {
        return this.theType;
    }
    
    public void setTheType(String theType) {
        this.theType = theType;
    }
    
    // get all the supported, updateable objects so we can populate a dropdown
    public List<SelectOption> getSupportedTypes() {
        return SelectOptionGenerator.getTypes(false);
    }
    
    // for testing purposes only
    public Configuration__c getRecord() {
        return (Configuration__c)stdController.getRecord();
    }

}