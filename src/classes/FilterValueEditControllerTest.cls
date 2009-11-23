// tests the controller for the filter value edit page
@IsTest
private class FilterValueEditControllerTest {

    static testMethod void testCreateValue() {
        // build a configuration and insert it
        Configuration__c conf = ConfigurationTestUtility.buildConfiguration();
        insert conf;

        // we have to set the retURL param for our controller to work        
        PageReference myPage = Page.FilterValueEdit;
        Test.setCurrentPage(myPage);
        ApexPages.currentPage().getParameters().put('retURL', '/' + conf.id);
        
        // build a filter value but don't insert it
        FilterValue__c fv = new FilterValue__c();
        ApexPages.StandardController stdCont = new ApexPages.StandardController(fv);
        FilterValueEditController cont = new FilterValueEditController(stdCont);
        System.assertEquals(fv.fieldname__c, cont.getName());
        System.assertEquals(fv.operator__c, cont.getOperator());
        
        // verify that the configuration's name is correct
        String configurationName = cont.getConfigurationName();
        System.assertEquals(conf.name, configurationName);
        
        cont.setName('newName');
        cont.setOperator('newOp');
        cont.save();
        FilterValue__c newFv = (FilterValue__c)cont.getRecord();
        System.assertEquals('newName', newFv.fieldname__c);
        System.assertEquals('newOp', newFv.operator__c);
        System.assertEquals(conf.id, newFv.configuration__c);
    }

    static testMethod void testUpdateValue() {
        // build a configuration and insert it
        Configuration__c conf = ConfigurationTestUtility.buildConfiguration();
        insert conf;
        // build a filter value and insert it with the previously created conf
        // as its parent
        FilterValue__c fv = FilterValueTestUtility.buildFilterValue(conf.id);
        insert fv;
        ApexPages.StandardController stdCont = new ApexPages.StandardController(fv);
        FilterValueEditController cont = new FilterValueEditController(stdCont);
        System.assertEquals(fv.fieldname__c, cont.getName());
        System.assertEquals(fv.operator__c, cont.getOperator());
        
        // verify that the configuration's name is correct
        String configurationName = cont.getConfigurationName();
        System.assertEquals(conf.name, configurationName);
        
        cont.setName('newName');
        cont.setOperator('newOp');
        cont.save();
        FilterValue__c newFv = (FilterValue__c)cont.getRecord();
        System.assertEquals('newName', newFv.fieldname__c);
        System.assertEquals('newOp', newFv.operator__c);
    }
    
    static testMethod void testGetterAndSetter() {
        FilterValue__c fv = new FilterValue__c();
        ApexPages.StandardController stdCont = new ApexPages.StandardController(fv);
        FilterValueEditController cont = new FilterValueEditController(stdCont);
        cont.setName('name');
        cont.setOperator('op');
        System.assertEquals('name', cont.getName());
        System.assertEquals('op', cont.getOperator());
    }

    static testMethod void testGetFilterableFields() {
        // build a configuration and insert it
        Configuration__c conf = ConfigurationTestUtility.buildConfiguration();
        insert conf;
        // build a filter value and insert it with the previously created conf
        // as its parent
        FilterValue__c fv = FilterValueTestUtility.buildFilterValue(conf.id);
        insert fv;
        ApexPages.StandardController stdCont = new ApexPages.StandardController(fv);
        FilterValueEditController cont = new FilterValueEditController(stdCont);
        List<SelectOption> filterableFields = cont.getFilterableFields();
        System.assert(filterableFields != null);
    }
    
    static testMethod void testGetOperators() {
        FilterValue__c fv = new FilterValue__c();
        ApexPages.StandardController stdCont = new ApexPages.StandardController(fv);
        FilterValueEditController cont = new FilterValueEditController(stdCont);
        List<SelectOption> operators = cont.getOperators();
        System.assert(operators != null);
    }

}