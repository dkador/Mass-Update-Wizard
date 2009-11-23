public class FilterValueTestUtility {
    
    public static FilterValue__c buildFilterValue(String configurationId) {
    	return buildFilterValue('fv name', 'name', '=', 'blah', configurationId);
    }

    public static FilterValue__c buildFilterValue(String name,
                                                  String fieldName,
                                                  String operator,
                                                  String filterValue,
                                                  String configurationId) {
        return buildFilterValue(name, fieldName, operator, filterValue, 'AND', configurationId);                                     
    }    
    
    public static FilterValue__c buildFilterValue(String name,
                                                  String fieldName,
                                                  String operator,
                                                  String filterValue,
                                                  String logicalJoin,
                                                  String configurationId) {
        FilterValue__c fv = new FilterValue__c();
      	fv.name = name;
        fv.fieldName__c = fieldName;
        fv.operator__c = operator;
        fv.filterValue__c = filterValue;
        fv.logicaljoin__c = logicaljoin;
        fv.configuration__c = configurationId;
        return fv;
    }
        
}