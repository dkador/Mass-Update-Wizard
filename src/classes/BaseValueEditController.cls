// this class is the base class that the FilterValue and UpdateValue
// edit controllers extend from. it defines a couple common things.
public abstract class BaseValueEditController {

    // this keeps track of the standard controller that the custom controller
    // extensions use
    protected ApexPages.StandardController stdController;
    // this String determines if we're dealing with a filter value or an update value
    protected String objectType;
    
    // gotta implement a save method
    public abstract PageReference save();

    // this finds the parent configuration's id. it will either be saved in the child
    // record or we'll have to pull it out of the retURL request parameter.
    protected String getConfigurationId() {
    	String objId = stdController.getId();
        String confId = null;
        // obj will either be an UpdateValue, a FilterValue, or a SelectValue, but we have
        // to find out which one it is
        if(objectType.equals('UpdateValue')) {
        	List<UpdateValue__c> uv = [select configuration__c from UpdateValue__c where id=:objId];
        	if(uv.size() == 1) {
        		confId = uv[0].configuration__c;
        	}
        } else if(objectType.equals('FilterValue')) {
        	List<FilterValue__c> fv = [select configuration__c from FilterValue__c where id=:objId];
        	if(fv.size() == 1) {
        		confId = fv[0].configuration__c;
        	}
        } else if(objectType.equals('SelectValue')) {
        	List<SelectValue__c> sv = [select configuration__c from SelectValue__c where id=:objId];
        	if(sv.size() == 1) {
        		confId = sv[0].configuration__c;
        	}
        }
        // if confId is null, then we're creating a new object rather than updating an
        // existing one, so we have to grab the id of the parent configuration
        if(confId == null) {
            confId = ApexPages.currentPage().getParameters().get('retURL');
            // have to strip out the leading / (actually %2F)
            confId = confId.substring(1);
        }
        return confId;
    }
    
    // this finds the configuration's name (for display in the edit page)
    // it should be protected but I'm making it public so I can test it
    public String getConfigurationName() {
    	Configuration__c conf = [select name from configuration__c where id=:getConfigurationId()];
    	return conf.name;
    }
    
    // used for testing, and it has to be public so that the test class can see it (ugh apex)
    public SObject getRecord() {
    	return stdController.getRecord();
    }
    
}