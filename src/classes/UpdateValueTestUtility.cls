public class UpdateValueTestUtility {
	
	public static UpdateValue__c buildUpdateValue(String name, 
	                                              String fieldName,
	                                              String fieldValue,
	                                              String configurationId) {
	    UpdateValue__c uv = new UpdateValue__c();
	    uv.name = name;
	    uv.fieldname__c = fieldName;
	    uv.fieldvalue__c = fieldValue;
	    uv.configuration__c = configurationId;
	    return uv;
	}

}