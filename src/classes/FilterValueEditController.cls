// this is the controller for the filter value edit page
public class FilterValueEditController extends BaseValueEditController {

    // keeps track of the field name
    private String name;
    // keeps track of the operator
    private String operator;

    // constructor for the custom controller extension
    public FilterValueEditController(ApexPages.StandardController stdController) {
        // set the controller
        this.stdController = stdController;
        this.objectType = 'FilterValue';
        // use a list because the query can return 0 or 1 record
        List<FilterValue__c> fv = [select id, fieldname__c, operator__c from filtervalue__c where id=:stdController.getId()];
        if(fv.size() == 1) {
            name = fv[0].fieldname__c;
            operator = fv[0].operator__c;
        }
    }
        
    // save the actual filter value
    public override PageReference save() {
        FilterValue__c fv = (FilterValue__c)stdController.getRecord();
        fv.fieldname__c = name;
        fv.operator__c = operator;
        // only need to set the configuration id if it hasn't already been set because it's a MD relationship
        // so you can't change it once it's set
        if(fv.configuration__c == null) {
           fv.configuration__c = getConfigurationId();
        }
        return stdController.save();
    }
    
    public String getName() {
        return this.name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public String getOperator() {
        return this.operator;
    }
    
    public void setOperator(String operator) {
        this.operator = operator;
    }
    
    // get all filterable fields
    public List<SelectOption> getFilterableFields() {
        String confId = getConfigurationId();
        Configuration__c c = [select type__c from configuration__c where id=:confId];
        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(c.type__c).getDescribe().fields.getMap();
        Map<String, Map<String, Schema.SObjectField>> parentFieldsMap = DescribeUtility.getParentFieldDescribeMaps(fieldsMap);
        return SelectOptionGenerator.getFields(c.type__c, false, true, true, false, false,
               fieldsMap, parentFieldsMap);
    }
    
    // get the operators
    public List<SelectOption> getOperators() {
        return SelectOptionGenerator.getOperators(null, null); 
    }
    
}