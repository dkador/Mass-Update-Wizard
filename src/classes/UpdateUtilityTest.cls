@IsTest
private class UpdateUtilityTest {
    
    static testMethod void testConstructor() {
        UpdateUtility util = null;
        MUWTestObject__c a = new MUWTestObject__c(name='Blah');
        insert a;
        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get('MUWTestObject__c').getDescribe().fields.getMap();
        QueryUtility queryUtil = new QueryUtility(null, 'MUWTestObject__c', 
          new FilterValue[] { new FilterValue('Id', '=', a.Id) },
          fieldsMap, null);
        UpdateValue[] updateValues = new UpdateValue[] { new UpdateValue('MUWTestObject__c', 'New Blah') };
        try {
            util = new UpdateUtility(null, updateValues, fieldsMap);
            System.assert(false, 'should have thrown exception!');
        } catch(MUWException e) {
            System.assertEquals('queryUtil cannot be null!', e.getMessage());
        }
        try {
            util = new UpdateUtility(queryUtil, null, fieldsMap);
            System.assert(false, 'should have thrown exception!');
        } catch(MUWException e) {
            System.assertEquals('updateValues cannot be null!', e.getMessage());
        }
        try {
            util = new UpdateUtility(queryUtil, updateValues, null);
            System.assert(false, 'should have thrown exception!');
        } catch(MUWException e) {
            System.assertEquals('fieldsMap cannot be null!', e.getMessage());
        }
    }
    
    static testMethod void testBasicUpdate() {
        MUWTestObject__c a = new MUWTestObject__c(name='Blah');
        insert a;
        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get('MUWTestObject__c').getDescribe().fields.getMap();
        QueryUtility queryUtil = new QueryUtility(null, 'MUWTestObject__c', 
                                        new FilterValue[] { new FilterValue('Id', '=', a.Id) },
                                        fieldsMap, null);
        UpdateValue[] updateValues = new UpdateValue[] { new UpdateValue('Name', 'New Blah') };
        UpdateUtility updateUtil = new UpdateUtility(queryUtil, updateValues, fieldsMap); 
        
        // do the update
        updateUtil.updateRecords();
        // verify that the record was updated
        MUWTestObject__c newA = [select id, name from MUWTestObject__c where id=:a.id];
        System.assertEquals('New Blah', newA.name);
    }
    
    static testMethod void testUpdateParent() {
    	MUWTestObject__c parent = new MUWTestObject__c(name='testparent');
        insert parent;
        MUWTestObject__c child = new MUWTestObject__c(name='testchild', MUW_Test_Object__c=parent.id);
        insert child;
        MUWTestObject__c otherparent = new MUWTestObject__c(name='testotherparent');
        insert otherparent;
        
        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get('MUWTestObject__c').getDescribe().fields.getMap();
        QueryUtility queryUtil = new QueryUtility(null, 'MUWTestObject__c', 
                                        new FilterValue[] { new FilterValue('Id', '=', child.Id) },
                                        fieldsMap, null);
        UpdateValue[] updateValues = new UpdateValue[] { new UpdateValue('muw__MUW_Test_Object__c', otherparent.id) };
        UpdateUtility updateUtil = new UpdateUtility(queryUtil, updateValues, fieldsMap); 
        
        // do the update
        updateUtil.updateRecords();
        // verify that the record was updated
        MUWTestObject__c newchild = [select id, muw__MUW_Test_Object__c from MUWTestObject__c where id=:child.id];
        System.assertEquals(otherparent.id, newchild.muw__MUW_Test_Object__c);
    }
    
    static testMethod void testBatchUpdate() {
        // set up 400 MUWTestObject__cs
        for(integer j=0; j<2; j++) {
            List<MUWTestObject__c> l = new List<MUWTestObject__c>();
            for(integer i=0; i<200; i++) {
                l.add(new MUWTestObject__c(name='dodo'));
            }
            insert l;
        }
        
        test.startTest();
        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get('MUWTestObject__c').getDescribe().fields.getMap();
        QueryUtility queryUtil = new QueryUtility(null,
                                        'MUWTestObject__c',
                                        new FilterValue[] { new FilterValue('Name', '=', 'dodo') },
                                        fieldsMap,
                                        null);
        UpdateValue[] updateValues = new UpdateValue[] { new UpdateValue('currency__c', '5.0') };
        UpdateUtility updateUtility = new UpdateUtility(queryUtil, updateValues, fieldsMap);
        integer recordCount = updateUtility.updateRecords();
        System.assertEquals(400, recordCount);
        for(MUWTestObject__c obj : [select id, name, currency__c from MUWTestObject__c where name='dodo']) {
            System.assertEquals(5.0, obj.currency__c);
        }
        test.stopTest();
    }
    
    static testMethod void testGetTypedFieldValue() {
    	Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get('MUWTestObject__c').getDescribe().fields.getMap();
        QueryUtility queryUtil = new QueryUtility(null, 'MUWTestObject__c', 
                                        new FilterValue[0],
                                        fieldsMap,
                                        null);
        UpdateValue[] updateValues = new UpdateValue[0];
        UpdateUtility updateUtil = new UpdateUtility(queryUtil, updateValues, fieldsMap); 

        // test boolean with true and false
        UpdateValue uv = UpdateValue.buildUpdateValue('boolean__c', 'true');
        Object val = updateUtil.getTypedFieldValue(uv);
        System.assertEquals(true, val);
        uv = UpdateValue.buildUpdateValue('boolean__c', 'false');
        val = updateUtil.getTypedFieldValue(uv);
        System.assertEquals(false, val);
        
        // test currency
        uv = UpdateValue.buildUpdateValue('currency__c', '50');
        val = updateUtil.getTypedFieldValue(uv);
        System.assertEquals(50.0, val);
        
        // test double
        uv = UpdateValue.buildUpdateValue('double__c', '50.123');
        val = updateUtil.getTypedFieldValue(uv);
        System.assertEquals(50.123, val);
        
        // test percent
        uv = UpdateValue.buildUpdateValue('percent__c', '50.123');
        val = updateUtil.getTypedFieldValue(uv);
        System.assertEquals(50.123, val);
        
        // test date
        uv = UpdateValue.buildUpdateValue('date__c', '2008-12-12');
        val = updateUtil.getTypedFieldValue(uv);
        System.assertEquals(Date.newInstance(2008, 12, 12), val);
        
        // test datetime
        uv = UpdateValue.buildUpdateValue('datetime__c', '2008-12-12 10:10:10');
        val = updateUtil.getTypedFieldValue(uv);
        System.assertEquals(DateTime.newInstance(2008, 12, 12, 10, 10, 10), val);
        
        // test integer (can't figure out how to make a custom field of type integer)
        //uv = UpdateValue.buildUpdateValue('integer__c', '50');
        //val = updateUtil.getTypedFieldValue(uv);
        //System.assertEquals(50, val);
    }

}