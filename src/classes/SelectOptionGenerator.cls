public class SelectOptionGenerator {
    
    public static List<SelectOption> getTypes(boolean showLabels) {
        List<SelectOption> options = new List<SelectOption>();
        options = addNone(options);
        List<String> types = MassUpdateWizardController.getAllTypes();
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        for(String aType : types) {
            Schema.DescribeSObjectResult result = gd.get(aType).getDescribe();
            if(result.isUpdateable()) {
                String optionName = result.getName();
                String optionLabel = result.getName();
                if(showLabels) {
                    optionLabel += ' (' + result.getLabel() + ')';
                } 
                options.add(new SelectOption(optionName, optionLabel)); 
            }
        }   
        return options;
    }
    
    public static List<SelectOption> getConfigurationOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(Constants.showLabels, 'Display object/field labels and names?'));
        options.add(new SelectOption(Constants.showParentFields, 'Include fields from parent relationships?'));
        return options; 
    }
    
    public static List<SelectOption> getFields(String selectedType, boolean showLabels,
            boolean checkIsFilterable, boolean isFilterable, 
            boolean checkIsUpdateable, boolean isUpdateable,
            Map<String, Schema.SObjectField> fieldsMap,
            Map<String, Map<String, Schema.SObjectField>> parentFieldsMap) {
        List<SelectOption> options = new List<SelectOption>();
        options = addNone(options);
        if(selectedType != null && !selectedType.equals(Constants.none)) {
            // set up a map from label+name -> sobject, then sort on that keyset
            Map<String, Schema.SObjectField> nameAndLabelFieldsMap = new Map<String, Schema.SObjectField>();
            List<String> sortedFieldNames = new List<String>();
            for(String fieldName : fieldsMap.keySet()) {
                String newKey = fieldsMap.get(fieldName).getDescribe().getLabel() + fieldName;
                sortedFieldNames.add(newKey);
                nameAndLabelFieldsMap.put(newKey, fieldsMap.get(fieldName));
            }
            sortedFieldNames.sort();
            for(String fieldName : sortedFieldNames) {
                Schema.SObjectField f = nameAndLabelFieldsMap.get(fieldName);
                Schema.DescribeFieldResult result = f.getDescribe();
                if(!result.isAccessible()) {
                	continue;
                }
                if((checkIsFilterable && isFilterable != result.isFilterable()) ||
                   (checkIsUpdateable && isUpdateable != result.isUpdateable())) {
                    continue;
                }
                // we have to go back to the original name
                String optionLabel = result.getLabel();
                integer labelLength = optionLabel.length();
                String optionName = fieldName.substring(labelLength);
                if(showLabels) {
                    optionLabel += ' (' + result.getName() + ')';   
                }
                options.add(new SelectOption(optionName, optionLabel));
            }
            // only include parents' fields if we're not checking for updateable stuff and
            // if the parent fields map isn't null
            if(!checkIsUpdateable && parentFieldsMap != null) {
            	System.debug('made it');
            	// go through the sorted field names and look for any that are relationship fields
	            for(String fieldName : sortedFieldNames) {
	            	Schema.SObjectField f = nameAndLabelFieldsMap.get(fieldName);
	            	System.debug('f: ' + f);
	            	// get the describe result for the field
	                Schema.DescribeFieldResult result = f.getDescribe();
	                System.debug('result: ' + result);
	                // can't do anything if the user can't see the field!
	                if(!result.isAccessible()) {
	                    continue;
	                }
	                // find all the sobjects to which the field can refer
	                List<Schema.SObjectType> parentTypes = result.getReferenceTo();
	                System.debug('parentTypes: ' + parentTypes);
	                if(parentTypes != null) {
	                	// get the relationship name
	                	String relationshipName = result.getRelationshipName();
	                	System.debug('relationshipName: ' + relationshipName);
	                	// iterate through the referrable types
	                	for(Schema.SObjectType sType : parentTypes) {
	                		// get the describe for the parent type
	                		Schema.DescribeSObjectResult parentResult = sType.getDescribe();
	                		System.debug('parentResult: ' + parentResult);
	                		// get the parent's name
	                		String parentName = parentResult.getLocalName();
	                		System.debug('parentName: ' + parentName);
	                		// get the fields map for the parent
	                		Map<String, Schema.SObjectField> parentMap = parentFieldsMap.get(parentName);
	                		System.debug('parentMap: ' + parentMap);
	                		// setup a map which keys off field label + name
	                		Map<String, Schema.SObjectField> parentNameAndLabelFieldsMap = new Map<String, Schema.SObjectField>();
	                		// setup a list of those keys so we can sort it
				            List<String> parentSortedFieldNames = new List<String>();
				            if(parentMap != null) {
					            // iterate through the parent's fields
					            for(String parentFieldName : parentMap.keySet()) {
					            	// construct the new key
					                String newKey = parentMap.get(parentFieldName).getDescribe().getLabel() + parentFieldName;
					                // add that key to the list of keys
					                parentSortedFieldNames.add(newKey);
					                // add that key and field to the map
					                parentNameAndLabelFieldsMap.put(newKey, parentMap.get(parentFieldName));
					            }
					            // sort the list of new keys
					            parentSortedFieldNames.sort();
					            // iterate through those keys
					            for(String sortedParentFieldName : parentSortedFieldNames) {
					            	Schema.SObjectField parentField = parentNameAndLabelFieldsMap.get(sortedParentFieldName);
					            	Schema.DescribeFieldResult parentFieldResult = parentField.getDescribe();
					            	// we have to go back to the original name
					                String parentFieldLabel = parentFieldResult.getLabel();
					                integer parentLabelLength = parentFieldLabel.length();
					                String parentFieldName = parentFieldResult.getName();
					                String optionName = relationshipName + '.' + sortedParentFieldName.substring(parentLabelLength);
					                String optionLabel = 'Parent ' + parentName + ' (' + relationshipName + ')' + ': ' + parentFieldLabel;
					                if(showLabels) {
					                    optionLabel += ' (' + parentFieldResult.getName() + ')';   
					                }
	                                options.add(new SelectOption(optionName, optionLabel));
	                                if(options.size() == 1000) {
	                                	return options;
	                                }
					            }
				            } else {
				            	// if parentMap is null, something weird happened. what was it? this will help us to find out, I hope.
	                			System.debug('selectedType: ' + selectedType);
	                			System.debug('parentName: ' + parentName);
	                			System.debug('parentTypes: ' + parentTypes);
	                			System.debug('fieldsMap: ' + fieldsMap);
	                			System.debug('parentFieldsMap: ' + parentFieldsMap);
				            }
	                	}
	                }
	            }
            }
        }
        return options;
    }
    
    public static List<SelectOption> getOperators(Map<String, Schema.SObjectField> fieldsMap, String fieldName) {
        List<SelectOption> options = new List<SelectOption>();
        options = addNone(options);
        options.add(new SelectOption('=', 'equals'));
        options.add(new SelectOption('!=', 'not equal to'));
        options.add(new SelectOption('startswith', 'starts with'));
        options.add(new SelectOption('contains', 'contains'));
        options.add(new SelectOption('doesnotcontain', 'does not contain'));
        options.add(new SelectOption('<', 'less than'));
        options.add(new SelectOption('>', 'greater than'));
        options.add(new SelectOption('<=', 'less than or equal'));
        options.add(new SelectOption('>=', 'greater than or equal'));
        if(fieldsMap != null && fieldsMap.containsKey(fieldName)) {
            Schema.DescribeFieldResult describeResult = fieldsMap.get(fieldName).getDescribe();
            if(describeResult.getType() == DisplayType.Picklist) {
                options.add(new SelectOption('in', 'in'));
                options.add(new SelectOption('not in', 'not in'));
            } else if(describeResult.getType() == DisplayType.MultiPicklist) {
	           options.add(new SelectOption('includes', 'includes'));
	           options.add(new SelectOption('excludes', 'excludes'));
            }
        }
        return options; 
    }
    
    public static List<SelectOption> getLogicalJoins() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('AND', 'AND'));
        options.add(new SelectOption('OR', 'OR'));
        return options;
    }
    
    private static List<SelectOption> addNone(List<SelectOption> options) {
        options.add(new SelectOption(Constants.none, Constants.none));
        return options;
    }
    
}