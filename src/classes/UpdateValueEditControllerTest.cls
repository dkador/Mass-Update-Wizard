@IsTest
private class UpdateValueEditControllerTest {

    static testMethod void testCreateValue() {
        // build a configuration and insert it
        Configuration__c conf = ConfigurationTestUtility.buildConfiguration();
        insert conf;

        // we have to set the retURL param for our controller to work        
        PageReference myPage = Page.UpdateValueEdit;
        Test.setCurrentPage(myPage);
        ApexPages.currentPage().getParameters().put('retURL', '/' + conf.id);
        
        // build a filter value but don't insert it
        UpdateValue__c uv = new UpdateValue__c();
        ApexPages.StandardController stdCont = new ApexPages.StandardController(uv);
        UpdateValueEditController cont = new UpdateValueEditController(stdCont);
        System.assertEquals(uv.fieldname__c, cont.getName());
        
        // verify that the configuration's name is correct
        String configurationName = cont.getConfigurationName();
        System.assertEquals(conf.name, configurationName);
        
        cont.setName('newName');
        cont.save();
        UpdateValue__c newUv = (UpdateValue__c)cont.getRecord();
        System.assertEquals('newName', newUv.fieldname__c);
        System.assertEquals(conf.id, newUv.configuration__c);
    }
    
    static testMethod void testUpdateValue() {
        // build a configuration and insert it
        Configuration__c conf = ConfigurationTestUtility.buildConfiguration();
        insert conf;

        // we have to set the retURL param for our controller to work        
        PageReference myPage = Page.UpdateValueEdit;
        Test.setCurrentPage(myPage);
        ApexPages.currentPage().getParameters().put('retURL', '/' + conf.id);
        
        // build a filter value and insert it
        UpdateValue__c uv = UpdateValueTestUtility.buildUpdateValue('newname', 'name', 'blah', conf.id);
        insert uv;
        ApexPages.StandardController stdCont = new ApexPages.StandardController(uv);
        UpdateValueEditController cont = new UpdateValueEditController(stdCont);
        System.assertEquals(uv.fieldname__c, cont.getName());
        
        // verify that the configuration's name is correct
        String configurationName = cont.getConfigurationName();
        System.assertEquals(conf.name, configurationName);
        
        cont.setName('newName');
        cont.save();
        UpdateValue__c newUv = (UpdateValue__c)cont.getRecord();
        System.assertEquals('newName', newUv.fieldname__c);
        System.assertEquals(conf.id, newUv.configuration__c);
    }
    
    static testMethod void testGetUpdateableFields() {
        Configuration__c conf = ConfigurationTestUtility.buildConfiguration('conf name', 'MUWTestObject__c');
        insert conf;
        UpdateValue__c uv = new UpdateValue__c();
        uv.configuration__c = conf.id;
        
        // we have to set the retURL param for our controller to work        
        PageReference myPage = Page.UpdateValueEdit;
        Test.setCurrentPage(myPage);
        ApexPages.currentPage().getParameters().put('retURL', '/' + conf.id);
        
        ApexPages.StandardController stdCont = new ApexPages.StandardController(uv);
        UpdateValueEditController cont = new UpdateValueEditController(stdCont);
        List<SelectOption> updateableFields = cont.getUpdateableFields();
    }

}