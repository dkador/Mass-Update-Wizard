@IsTest
private class SelectOptionGeneratorTest {

    static testMethod void testGetTypes() {
        Map<String, Schema.SObjectType> m = Schema.getGlobalDescribe();
        integer count = 0;
        for(Schema.SObjectType obj : m.values()) {
            if(obj.getDescribe().isUpdateable()) {
                count++;
            }
        }
        List<SelectOption> optionsNoLabels = SelectOptionGenerator.getTypes(false);
        // we add one for the none field
        System.assertEquals(count + 1, optionsNoLabels.size());
        
        List<SelectOption> optionsLabels = SelectOptionGenerator.getTypes(true);
        System.assertEquals(optionsNoLabels.size(), optionsLabels.size());
        // now we assert the values in the labels list all include the corresponding values
        // and are longer
        for(integer i=1; i<optionsLabels.size(); i++) {
            System.assertEquals(optionsLabels[i].getValue(), optionsNoLabels[i].getValue());
            System.assert(optionsLabels[i].getLabel().contains(optionsNoLabels[i].getLabel()));
            System.assert(optionsLabels[i].getLabel().length() > optionsNoLabels[i].getLabel().length());
        }
    }
    
    // this is a pretty naive test
    static testMethod void testGetConfigurationOptions() {
        List<SelectOption> options = SelectOptionGenerator.getConfigurationOptions();
        System.assertEquals(2, options.size());
    }
    
    static testMethod void testGetFields() {
        Map<String, Schema.SObjectField> fieldsMap = MUWTestObject__c.sObjectType.getDescribe().fields.getMap();
        System.debug('fieldsMap: ' + fieldsMap);
        Map<String, Map<String, Schema.SObjectField>> parentFieldsMap = new Map<String, Map<String, Schema.SObjectField>>();
        parentFieldsMap.put('MUWTestObject__c', MUWTestObject__c.sObjectType.getDescribe().fields.getMap());
        
        List<SelectOption> optionsNoLabels = SelectOptionGenerator.getFields('MUWTestObject__c', false, false, false, false, false, fieldsMap, parentFieldsMap);
        List<SelectOption> optionsLabels = SelectOptionGenerator.getFields('MUWTestObject__c', true, false, false, false, false, fieldsMap, parentFieldsMap);
        
        System.debug('optionsNoLabels size: ' + optionsNoLabels.size());
        for(SelectOption o : optionsNoLabels) {
        	System.debug(o.getLabel() + ': ' + o.getValue());
        }
        
        System.assertEquals(fieldsMap.size()*2 + 1, optionsNoLabels.size());
        System.assertEquals(optionsNoLabels.size(), optionsLabels.size());
        for(integer i=1; i<optionsLabels.size(); i++) {
            System.assertEquals(optionsLabels[i].getValue(), optionsNoLabels[i].getValue());
            System.assert(optionsLabels[i].getLabel().contains(optionsNoLabels[i].getLabel()));
            System.assert(optionsLabels[i].getLabel().length() > optionsNoLabels[i].getLabel().length());
        }
        
        // now verify that we filter appropriately
        List<SelectOption> optionsFiltered = SelectOptionGenerator.getFields('MUWTestObject__c', false, true, true, true, true, fieldsMap, parentFieldsMap);
        integer count = 0;
        for(Schema.SObjectField f : fieldsMap.values()) {
            if(f.getDescribe().isUpdateable() && f.getDescribe().isFilterable()) {
                count++;
            }
        }
        System.assertEquals(count + 1, optionsFiltered.size());
    }
    
    static testMethod void testGetOperators() {
        List<SelectOption> options = SelectOptionGenerator.getOperators(null, null);
        System.assertEquals(10, options.size());
        // verify that in/not in show up for picklist fields
        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get('MUWTestObject__c').getDescribe().fields.getMap();
        options = SelectOptionGenerator.getOperators(fieldsMap, 'picklist__c');
        System.assertEquals(12, options.size());
        System.assertEquals('in', options[10].getValue());
        System.assertEquals('not in', options[11].getValue());
        // verify that includes/excludes show up for multi-select picklist fields
        options = SelectOptionGenerator.getOperators(fieldsMap, 'msp__c');
        System.assertEquals(12, options.size());
        System.assertEquals('includes', options[10].getValue());
        System.assertEquals('excludes', options[11].getValue());
    }
    
    // tests that the select options are generated properly for the logical joins
    static testMethod void testGetLogicalJoins() {
    	List<SelectOption> options = SelectOptionGenerator.getLogicalJoins();
    	System.assertEquals(2, options.size());
    	System.assertEquals('AND', options[0].getValue());
    	System.assertEquals('OR', options[1].getValue());
    }

}