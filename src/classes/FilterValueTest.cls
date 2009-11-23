@IsTest
private class FilterValueTest {
    
    static testMethod void testConstructor() {
        FilterValue val = null;
        try {
            val = new FilterValue(null, 'def', 'ghi', 'AND');
            System.assert(false, 'exception should have been thrown');
        } catch(MUWException e) {
            System.assertEquals('The filter criteria\'s field name must be specified!', e.getMessage());
        }
        try {
            val = new FilterValue(Constants.none, 'def', 'ghi', 'AND');
            System.assert(false, 'exception should have been thrown');
        } catch(MUWException e) {
            System.assertEquals('The filter criteria\'s field name must be specified!', e.getMessage());
        }
        try {
            val = new FilterValue('abc', null, 'ghi', 'AND');
            System.assert(false, 'exception should have been thrown');
        } catch(MUWException e) {
            System.assertEquals('The filter criteria\'s operator must be specified!', e.getMessage());
        }
        try {
            val = new FilterValue('abc', Constants.none, 'ghi', 'AND');
            System.assert(false, 'exception should have been thrown');
        } catch(MUWException e) {
            System.assertEquals('The filter criteria\'s operator must be specified!', e.getMessage());
        }
        try {
            val = new FilterValue('abc', 'def', null, 'AND');
            System.assert(false, 'exception should have been thrown');
        } catch(MUWException e) {
            System.assertEquals('The filter criteria\'s field value must be specified!', e.getMessage());
        }
        
        val = new FilterValue('abc', 'def', 'ghi', 'AND');
        System.assertEquals('abc', val.getFieldName());
        System.assertEquals('def', val.getOperator());
        System.assertEquals('ghi', val.getFieldValue());
    }
    
    static testMethod void testBuildFilterValue() {
        FilterValue val = FilterValue.buildFilterValue(Constants.none, Constants.none, '', 'AND');
        System.assertEquals(null, val);
        
        val = FilterValue.buildFilterValue('abc', 'def', 'ghi', 'AND');
        System.assertEquals('abc', val.getFieldName());
        System.assertEquals('def', val.getOperator());
        System.assertEquals('ghi', val.getFieldValue());
    }
    
    static testMethod void testAddFilterValueToList() {
        List<FilterValue> values = new List<FilterValue>();
        values = FilterValue.addFilterValueToList('abc', 'def', 'ghi', 'AND', values);
        System.assertEquals(1, values.size());
        System.assertEquals('abc', values[0].getFieldName());
        System.assertEquals('def', values[0].getOperator());
        System.assertEquals('ghi', values[0].getFieldValue());
        
        values = FilterValue.addFilterValueToList(Constants.none, Constants.none, '', 'AND', values);
        System.assertEquals(1, values.size());
    }

}