public class UpdateValueEditController extends BaseValueEditController {

    private String name;

    public UpdateValueEditController(ApexPages.StandardController stdController) {
        this.stdController = stdController;
        this.objectType = 'UpdateValue';
        List<UpdateValue__c> uv = [select id, fieldname__c from updatevalue__c where id=:stdController.getId()];
        if(uv.size() == 1) {
            name = uv[0].fieldname__c;
        }
    }
        
    public override PageReference save() {
        UpdateValue__c uv = (UpdateValue__c)stdController.getRecord();
        uv.fieldname__c = name;
        if(uv.configuration__c == null) {
            uv.configuration__c = getConfigurationId();
        }
        return stdController.save();
    }
    
    public String getName() {
        return this.name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public List<SelectOption> getUpdateableFields() {
        String confId = getConfigurationId();
        Configuration__c c = [select type__c from configuration__c where id=:confId];
        return SelectOptionGenerator.getFields(c.type__c, false, false, false, true, true,
               Schema.getGlobalDescribe().get(c.type__c).getDescribe().fields.getMap(), null);
    }
    
}