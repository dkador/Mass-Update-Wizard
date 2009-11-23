@IsTest
private class UpdateValueTest {

    static testMethod void testConstructor() {
        UpdateValue val = null;
        try {
            val = new UpdateValue(null, 'blah');
            System.assert(false, 'should have thrown exception!');
        } catch(MUWException e) {
            System.assertEquals('The update value\'s field name must be specified!', e.getMessage());
        }
        try {
            val = new UpdateValue(Constants.none, 'blah');
            System.assert(false, 'should have thrown exception!');
        } catch(MUWException e) {
            System.assertEquals('The update value\'s field name must be specified!', e.getMessage());
        }
        try {
            val = new UpdateValue('rafg', null);
            System.assert(false, 'should have thrown exception!');
        } catch(MUWException e) {
            System.assertEquals('The update value\'s field value must be specified!', e.getMessage());
        }
        
        val = new UpdateValue('abc', 'def');
        System.assertEquals('abc', val.getFieldName());
        System.assertEquals('def', val.getFieldValue());
    }
    
    static testMethod void testBuildUpdateValue() {
        UpdateValue val = UpdateValue.buildUpdateValue(Constants.none, '');
        System.assertEquals(null, val);
        
        val = UpdateValue.buildUpdateValue('abc', 'def');
        System.assertEquals('abc', val.getFieldName());
        System.assertEquals('def', val.getFieldValue());
    }
    
    static testMethod void testAddUpdateValueToList() {
        List<UpdateValue> values = new List<UpdateValue>();
        values = UpdateValue.addUpdateValueToList('abc', 'def', values);
        System.assertEquals(1, values.size());
        System.assertEquals('abc', values[0].getFieldName());
        System.assertEquals('def', values[0].getFieldValue());
        
        values = UpdateValue.addUpdateValueToList(Constants.none, '', values);
        System.assertEquals(1, values.size());
    }

}