// testing class to easily build configuration objects
public class ConfigurationTestUtility {

    // this provides pre-existing values
    public static Configuration__c buildConfiguration() {
    	return buildConfiguration('name', 'MUWTestObject__c');
    }

    // builds the configuration and sets the name and type
    public static Configuration__c buildConfiguration(String name, String theType) {
    	// build the configuration
    	Configuration__c conf = new Configuration__c();
    	// set the name
    	conf.name = name;
    	// set the type
    	conf.type__c = theType;
    	// return the configuration
    	return conf;
    }

}