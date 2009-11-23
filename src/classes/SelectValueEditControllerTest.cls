@IsTest
private class SelectValueEditControllerTest {

    static testMethod void testCreateValue() {
        // build a configuration and insert it
        Configuration__c conf = ConfigurationTestUtility.buildConfiguration();
        insert conf;

        // we have to set the retURL param for our controller to work        
        PageReference myPage = Page.FilterValueEdit;
        Test.setCurrentPage(myPage);
        ApexPages.currentPage().getParameters().put('retURL', '/' + conf.id);
        
        // build a select value but don't insert it
        SelectValue__c sv = new SelectValue__c();
        ApexPages.StandardController stdCont = new ApexPages.StandardController(sv);
        SelectValueEditController cont = new SelectValueEditController(stdCont);
        System.assertEquals(sv.fieldname__c, cont.getFieldName());
        
        // verify that the configuration's name is correct
        String configurationName = cont.getConfigurationName();
        System.assertEquals(conf.name, configurationName);
        
        cont.setFieldName('newName');
        cont.save();
        SelectValue__c newsv = (SelectValue__c)cont.getRecord();
        System.assertEquals('newName', newsv.fieldname__c);
        System.assertEquals(conf.id, newsv.configuration__c);
    }

    static testMethod void testUpdateValue() {
        // build a configuration and insert it
        Configuration__c conf = ConfigurationTestUtility.buildConfiguration();
        insert conf;
        // build a select value and insert it with the previously created conf
        // as its parent
        SelectValue__c sv = SelectValueTestUtility.buildSelectValue(conf.id);
        insert sv;
        ApexPages.StandardController stdCont = new ApexPages.StandardController(sv);
        SelectValueEditController cont = new SelectValueEditController(stdCont);
        System.assertEquals(sv.fieldname__c, cont.getFieldName());
        
        // verify that the configuration's name is correct
        String configurationName = cont.getConfigurationName();
        System.assertEquals(conf.name, configurationName);
        
        cont.setFieldName('newName');
        cont.save();
        SelectValue__c newsv = (SelectValue__c)cont.getRecord();
        System.assertEquals('newName', newsv.fieldname__c);
    }
    
    static testMethod void testGetterAndSetter() {
        SelectValue__c sv = new SelectValue__c();
        ApexPages.StandardController stdCont = new ApexPages.StandardController(sv);
        SelectValueEditController cont = new SelectValueEditController(stdCont);
        cont.setFieldName('name');
        System.assertEquals('name', cont.getFieldName());
    }

    static testMethod void testGetQueryableFields() {
        // build a configuration and insert it
        Configuration__c conf = ConfigurationTestUtility.buildConfiguration();
        insert conf;
        // build a select value and insert it with the previously created conf
        // as its parent
        SelectValue__c sv = SelectValueTestUtility.buildSelectValue(conf.id);
        insert sv;
        ApexPages.StandardController stdCont = new ApexPages.StandardController(sv);
        SelectValueEditController cont = new SelectValueEditController(stdCont);
        List<SelectOption> queryableFields = cont.getQueryableFields();
        System.assert(queryableFields != null);
    }
    
}