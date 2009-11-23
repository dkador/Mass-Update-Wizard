public class SelectValueEditController extends BaseValueEditController {

    // keeps track of the field name
    private String fieldName;

    // constructor for the custom controller extension
    public SelectValueEditController(ApexPages.StandardController stdController) {
        // set the controller
        this.stdController = stdController;
        this.objectType = 'SelectValue';
        // use a list because the query can return 0 or 1 record
        List<SelectValue__c> sv = [select id, fieldname__c from selectvalue__c where id=:stdController.getId()];
        if(sv.size() == 1) {
            this.fieldName = sv[0].fieldname__c;
        }
    }
    
    // save the actual filter value
    public override PageReference save() {
    	SelectValue__c sv = (SelectValue__c)stdController.getRecord();
    	sv.fieldname__c = fieldName;
        // only need to set the configuration id if it hasn't already been set because it's a MD relationship
        // so you can't change it once it's set
        if(sv.configuration__c == null) {
           sv.configuration__c = getConfigurationId();
        }
        return stdController.save();
    }
    
    // get all filterable fields
    public List<SelectOption> getQueryableFields() {
        String confId = getConfigurationId();
        Configuration__c c = [select type__c from configuration__c where id=:confId];
        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(c.type__c).getDescribe().fields.getMap();
        Map<String, Map<String, Schema.SObjectField>> parentFieldsMap = DescribeUtility.getParentFieldDescribeMaps(fieldsMap);
        return SelectOptionGenerator.getFields(c.type__c, false, false, false, false, false,
               fieldsMap, parentFieldsMap);
    }
    
    public String getFieldName() {
    	return this.fieldName;
    }
    
    public void setFieldName(String fieldName) {
    	this.fieldName = fieldName;
    }
    
}