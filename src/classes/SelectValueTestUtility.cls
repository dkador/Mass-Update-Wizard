public class SelectValueTestUtility {

    public static SelectValue__c buildSelectValue(String configurationId) {
        return buildSelectValue('sv name', 'name', configurationId);
    }

    public static SelectValue__c buildSelectValue(String name,
                                                  String fieldName,
                                                  String configurationId) {
        SelectValue__c sv = new SelectValue__c();
        sv.name = name;
        sv.fieldName__c = fieldName;
        sv.configuration__c = configurationId;
        return sv;
    }

}