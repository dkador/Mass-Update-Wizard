public class DescribeUtility {

    public static Map<String, Map<String, Schema.SObjectField>> getParentFieldDescribeMaps(Map<String, Schema.SObjectField> fieldsMap) {
    	// setup the data structure that will contain the fields of all the parents
    	Map<String, Map<String, Schema.SObjectField>> parentFieldsMap = new Map<String, Map<String, Schema.SObjectField>>();
    	// iterate over the fields in the root object's describe
    	for(Schema.SObjectField f : fieldsMap.values()) {
    		// get the objects this particular field points to
            List<Schema.SObjectType> parentDescribes = f.getDescribe().getReferenceTo();
            // only do this if the parent objects of this field isn't null
            if(parentDescribes != null) {
            	// iterate over the parents objects this field points to
                for(Schema.SObjectType sType : parentDescribes) {
                	// get the describe result for this object
                    Schema.DescribeSObjectResult describeResult = sType.getDescribe();
                    // if the particular object's describe doesn't already exist in the map, add it
                    if(!parentFieldsMap.containsKey(describeResult.getLocalName())) {
                        parentFieldsMap.put(describeResult.getLocalName(), describeResult.fields.getMap());
                    }
                }
            } 
        }
    	return parentFieldsMap;
    } 

}