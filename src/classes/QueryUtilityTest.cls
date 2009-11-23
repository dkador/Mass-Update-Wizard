@IsTest
private class QueryUtilityTest {

    private static Map<String, Schema.SObjectField> getFieldsMap(String sobjectType) {
        return Schema.getGlobalDescribe().get(sobjectType).getDescribe().fields.getMap();
    }
    
    static testMethod void testConstructor() {
        QueryUtility util = null;
        try {
            util = new QueryUtility(null, null, new FilterValue[0], getFieldsMap('MUWTestObject__c'), null);
            System.assert(false, 'exception should have been thrown!');
        } catch(MUWException e) {
            System.assertEquals('selectedType cannot be null or not-selected!', e.getMessage());
        }
        try {
            util = new QueryUtility(null, Constants.none, new FilterValue[0], getFieldsMap('MUWTestObject__c'), null);
            System.assert(false, 'exception should have been thrown!');
        } catch(MUWException e) {
            System.assertEquals('selectedType cannot be null or not-selected!', e.getMessage());
        }
        try {
            util = new QueryUtility(null, 'MUWTestObject__c', new FilterValue[0], null, null);
            System.assert(false, 'exception should have been thrown!');
        } catch(MUWException e) {
            System.assertEquals('fieldsMap cannot be null!', e.getMessage());
        }
    }
    
    static testMethod void testGenerateQuery() {
        String[] selectedFields = new String[] { 'Name', 'boolean__c', 'currency__c' };
        String sobjectType = 'MUWTestObject__c';
        FilterValue[] filterValues = new FilterValue[] {
            new FilterValue('Name', '=', 'blah'),
            new FilterValue('boolean__c', '!=', 'true'),
            new FilterValue('currency__c', '>', '15.0'),
            new FilterValue('double__c', '<', '53.0')
        };
        QueryUtility util = new QueryUtility(selectedFields, sobjectType, filterValues, getFieldsMap(sobjectType), null);
        
        // build the query
        String queryString = util.generateQuery(false);
        System.assert(queryString != null);
        List<SObject> objs = Database.query(queryString);
        System.assert(objs != null);
        
        // build the count query
        queryString = util.generateQuery(true);
        integer recordCount = Database.countQuery(queryString);
        System.assert(recordCount >= 0);
        
        // build the query with id a selected field
        selectedFields.add('Id');
        util = new QueryUtility(selectedFields, sobjectType, filterValues, getFieldsMap(sobjectType), null);
        queryString = util.generateQuery(false);
        objs = Database.query(queryString);
        System.assert(objs != null);
        
        // build the query with no fields selected
        util = new QueryUtility(null, sobjectType, filterValues, getFieldsMap(sobjectType), null);
        queryString = util.generateQuery(false);
        objs = Database.query(queryString);
        System.assert(objs != null);
        
        // build the query where you filter on a picklist and a multi-select picklist
        // and when you have a startswith, contains, and doesnotcontain
        selectedFields = null;
        sobjectType = 'MUWTestObject__c';
        filterValues = new List<FilterValue>();
        FilterValue.addFilterValueToList('picklist__c', 'in', 'a', 'AND', filterValues);
        FilterValue.addFilterValueToList('msp__c', 'includes', 'a', 'AND', filterValues);
        FilterValue.addFilterValueToList('name', 'startswith', 'a', 'AND', filterValues);
        FilterValue.addFilterValueToList('name', 'contains', 'a', 'AND', filterValues);
        FilterValue.addFilterValueToList('name', 'doesnotcontain', 'a', 'AND', filterValues);
        util = new QueryUtility(selectedFields, sobjectType, filterValues, getFieldsMap(sobjectType), null);
        queryString = util.generateQuery(false);
        objs = Database.query(queryString);
        System.assert(objs != null);
    }
    
    static testMethod void testParentRelationshipQuery() {
        String[] selectedFields = null;
        String sobjectType = 'MUWTestObject__c';
        FilterValue[] filterValues = new FilterValue[0];
        FilterValue.addFilterValueToList('muw__MUW_Test_Object__r.name', '=', 'blah', 'AND', filterValues);
        Map<String, Map<String, Schema.SObjectField>> parentFieldsMap =
               new Map<String, Map<String, Schema.SObjectField>>();
        
        Schema.DescribeSObjectResult toResult = MUWTestObject__c.getSobjectType().getDescribe();
        Map<String, Schema.SObjectField> toFieldsMap = toResult.fields.getMap();
        for(Schema.SObjectField toField : toFieldsMap.values()) {
            Schema.DescribeFieldResult toFieldResult = toField.getDescribe();
            List<Schema.SObjectType> references = toFieldResult.getReferenceTo();
            for(Schema.SObjectType ref : references) {
                parentFieldsMap.put(ref.getDescribe().getLocalName(), ref.getDescribe().fields.getMap());
            }
        }
        
        QueryUtility util = new QueryUtility(selectedFields, sobjectType, filterValues, toResult.fields.getMap(), parentFieldsMap);
        Test.startTest();
        String queryString = util.generateQuery(false);
        Test.stopTest();
    }
    
    static testMethod void testGetTableHtml() {
    	String[] selectedFields = new String[] { 'muw__MUW_Test_Object__r.id', 'id', 'muw__MUW_Test_Object__r.name' };
        String sobjectType = 'MUWTestObject__c';
        FilterValue[] filterValues = new FilterValue[0];
        FilterValue.addFilterValueToList('muw__MUW_Test_Object__r.name', '=', 'parent1', 'AND', filterValues);
        Map<String, Map<String, Schema.SObjectField>> parentFieldsMap =
               new Map<String, Map<String, Schema.SObjectField>>();
        
        Schema.DescribeSObjectResult toResult = MUWTestObject__c.getSobjectType().getDescribe();
        Map<String, Schema.SObjectField> toFieldsMap = toResult.fields.getMap();
        for(Schema.SObjectField toField : toFieldsMap.values()) {
            Schema.DescribeFieldResult toFieldResult = toField.getDescribe();
            List<Schema.SObjectType> references = toFieldResult.getReferenceTo();
            for(Schema.SObjectType ref : references) {
                parentFieldsMap.put(ref.getDescribe().getLocalName(), ref.getDescribe().fields.getMap());
            }
        }
        
        QueryUtility util = new QueryUtility(selectedFields, sobjectType, filterValues, toResult.fields.getMap(), parentFieldsMap);
        
        MUWTestObject__c parent = new MUWTestObject__c(name='parent1');
        insert parent;
        MUWTestObject__c child = new MUWTestObject__c(name='child1', MUW_Test_Object__c=parent.id);
        insert child;
        
        System.assertEquals(1, util.getNumberOfRecords(), 'wrong number of records found!');
        
        Test.startTest();
        String tableHtml = util.getTableHtml();
        Test.stopTest();
    }
    
}