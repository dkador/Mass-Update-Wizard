public with sharing class MassUpdateWizardController {
    
    // apex merge variables used in the various forms
    private String selectedType;
    private String[] selectedOptions = new String[0];
    // these keep track of all the field names we use to filter 
    private String filteredField1;
    private String filteredField2;
    private String filteredField3;
    private String filteredField4;
    private String filteredField5;
    // these keep track of all the operators we use to filter
    private String selectedOperator1;
    private String selectedOperator2;
    private String selectedOperator3;
    private String selectedOperator4;
    private String selectedOperator5;
    // these keep track of all the values we use to compare in the filter
    private String comparisonValue1;
    private String comparisonValue2;
    private String comparisonValue3;
    private String comparisonValue4;
    private String comparisonValue5;
    // these keep track of all the choices made for the logical joins
    private String logicalJoin1;
    private String logicalJoin2;
    private String logicalJoin3;
    private String logicalJoin4;
    // these keep track of all the field names we want to display back to the user
    private String queriedField1;
    private String queriedField2;
    private String queriedField3;
    private String queriedField4;
    private String queriedField5;
    // these keep track of all the update field names and their values
    private String updateField1;
    private String updateValue1;
    private String updateField2;
    private String updateValue2;
    private String updateField3;
    private String updateValue3;
    private String updateField4;
    private String updateValue4;
    private String updateField5;
    private String updateValue5;
    
    // this keeps track of whether or not to render the update button
    private boolean showUpdateButton = false;
    
    // this keeps track of the message we display to users
    private String recordCountMessage;
    private String updateMessage;
    
    
    // store the describe results so we don't have to re-execute them and run into governor limits
    Schema.SObjectType selectedTypeInfo;
    Map<String, Schema.SObjectField> fieldsMap;
    Map<String, Map<String, Schema.SObjectField>> parentFieldsMap = new Map<String, Map<String, Schema.SObjectField>>();
    
    private static List<String> allTypes;


    // all the different actions takeable from the apex page
    // this does nothing, but we need an action to actually do nothing
    public PageReference doNothing() {
    	resetStatus();
        return null;
    }
    
    private void resetStatus() {
    	// reset update/error messages
    	this.updateMessage = '';
    	this.recordCountMessage = '';
    	// turn off the update panel
    	this.showUpdateButton = false;
    }
    
    private QueryUtility generateQueryUtility(String[] selectedFields) {
    	// check if the type's been set
        if(selectedType == null || Constants.none.equals(selectedType)) {
            updateMessage = Constants.noObjectTypeErrorMessage;
            return null;
        }       
        // construct the list that holds all the filter values
        FilterValue[] filterValues = new FilterValue[0];
        // add any fully constructed filter values (erroring on any partly-constructed values)
        try {
	        filterValues = FilterValue.addFilterValueToList(filteredField1, selectedOperator1, comparisonValue1, logicalJoin1, filterValues);
	        filterValues = FilterValue.addFilterValueToList(filteredField2, selectedOperator2, comparisonValue2, logicalJoin2, filterValues);
	        filterValues = FilterValue.addFilterValueToList(filteredField3, selectedOperator3, comparisonValue3, logicalJoin3, filterValues);
	        filterValues = FilterValue.addFilterValueToList(filteredField4, selectedOperator4, comparisonValue4, logicalJoin4, filterValues);
	        filterValues = FilterValue.addFilterValueToList(filteredField5, selectedOperator5, comparisonValue5, null, filterValues);
        } catch(Exception e) {
        	updateMessage = Constants.getExceptionErrorMessage(e.getMessage());
        	return null;
        }
        // verify at least one filter value was added
        if(filterValues.size() == 0) {
            updateMessage = Constants.noFiltersErrorMessage;
            return null;
        }
        return new QueryUtility(selectedFields, selectedType, filterValues, fieldsMap, parentFieldsMap);
    }

    public PageReference findAffectedRecords() {
    	resetStatus();
    	
    	// setup the list of selectedFields
    	Set<String> selectedFields = new Set<String>();
    	if(!queriedField1.equals(Constants.none)) {
    		selectedFields.add(queriedField1);
    	}
        if(!queriedField2.equals(Constants.none)) {
            selectedFields.add(queriedField2);
        }
        if(!queriedField3.equals(Constants.none)) {
            selectedFields.add(queriedField3);
        }
        if(!queriedField4.equals(Constants.none)) {
            selectedFields.add(queriedField4);
        }
        if(!queriedField5.equals(Constants.none)) {
            selectedFields.add(queriedField5);
        }
    	
    	QueryUtility queryUtil = generateQueryUtility(new List<String>(selectedFields));
    	
    	if(queryUtil == null) {
            return null;
        }
        Integer recordCount = 0;
        try {
            recordCount = queryUtil.getNumberOfRecords();
        } catch(System.QueryException e) {
        	updateMessage = Constants.getUnknownQueryProblemErrorMessage(e.getMessage());
        	return null;
        }
        this.showUpdateButton = true;
        // set the appropriate update message based on the number of updated records
        if(recordCount == 10000) {
            recordCountMessage = Constants.tooManyMatchingRecordsErrorMessage;
            this.showUpdateButton = false;
        } else if(recordCount == 0) {
            recordCountMessage = Constants.noValuesUpdatedMessage;
            this.showUpdateButton = false;
        } else {
        	// if the user didn't select and fields to display, let's just show how many match
        	if(selectedFields.size() == 0) {
        	    recordCountMessage = 'Found ' + recordCount + ' matching record(s)!';
        	// if there are too many matching records we can't show them all
        	} else if(recordCount > 500) {
        		recordCountMessage = 'There are too many matching records to display detailed information on all of them. Found ' 
        		  + recordCount + ' matching record(s)! Are you certain you want to update all of them?';
        	// otherwise show all the matching records in a table 
        	} else {
        	    recordCountMessage = queryUtil.getTableHtml();
        	}
        }
    	
    	return null;
    }
    
    public PageReference updateRecords() {
    	resetStatus();
        QueryUtility queryUtil = generateQueryUtility(null);
    	if(queryUtil == null) {
    		return null;
    	}
        
        UpdateValue[] updateValues = new UpdateValue[0];
        // add any fully constructed update values (erroring on any partly-constructed values)
        try {
	        updateValues = UpdateValue.addUpdateValueToList(updateField1, updateValue1, updateValues);
	        updateValues = UpdateValue.addUpdateValueToList(updateField2, updateValue2, updateValues);
	        updateValues = UpdateValue.addUpdateValueToList(updateField3, updateValue3, updateValues);
	        updateValues = UpdateValue.addUpdateValueToList(updateField4, updateValue4, updateValues);
	        updateValues = UpdateValue.addUpdateValueToList(updateField5, updateValue5, updateValues);
        } catch(Exception e) {
        	updateMessage = Constants.getExceptionErrorMessage(e.getMessage());
        	return null;
        }
        // verify at least one update value was added
        if(updateValues.size() == 0) {
            updateMessage = Constants.noUpdateValuesErrorMessage;
            return null;
        }
        UpdateUtility updateUtil = new UpdateUtility(queryUtil, updateValues, fieldsMap);
        // update the matched records
        integer recordCount;
        try {
            recordCount = updateUtil.updateRecords();
        } catch(System.Exception e) {
        	if(e.getMessage().equals('includes or excludes operator only valid on multipicklist field')) {
        		updateMessage = 'Inclues or excludes can only be used with fields that are multi-select picklists! Please change your configuration.';
        	} else {
        		updateMessage = 'An unexpected error occurred! The error message is: ' + e.getMessage() + '.  Please send an e-mail with this information to dkador@salesforce.com so I can fix this!';
        	}
        	System.debug('The caught exception: ' + e);
        	return null;
        }
        // set the appropriate update message based on the number of updated records
        if(recordCount == 0) {
            updateMessage = Constants.noValuesUpdatedMessage;
        } else if(recordCount > 10000) {
            updateMessage = Constants.tooManyMatchingRecordsErrorMessage;
        } else {
            updateMessage = Constants.getSuccessfulUpdateMessage(recordCount);
        }
        return null;    
    }
    
    
    // getters and setters for the apex merge variables
    public String getSelectedType() {
        return this.selectedType;
    }
    
    public void setSelectedType(String selectedType) {
        this.selectedType = selectedType;
        // also cache the sobjecttype and fields
        this.selectedTypeInfo = Schema.getGlobalDescribe().get(selectedType);
        this.fieldsMap = selectedTypeInfo.getDescribe().fields.getMap();
        // find the supported parent types too if the option is on
        setupParentFields();
    }
    
    private void setupParentFields() {
    	// find the supported parent types too if the option is on
        if(OptionsUtility.getShowParentFields(this.selectedOptions)) {
            this.parentFieldsMap = DescribeUtility.getParentFieldDescribeMaps(this.fieldsMap);
        } else {
            this.parentFieldsMap = null;
        }
    }
    
    public String[] getSelectedOptions() {
        return this.selectedOptions;
    }
    
    public void setSelectedOptions(String[] selectedOptions) {
        this.selectedOptions = selectedOptions;
        setupParentFields();
    }
    
    public String getFilteredField1() {
        return this.filteredField1;
    }
    
    public void setFilteredField1(String filteredField) {
        this.filteredField1 = filteredField;
    }
    
    public String getFilteredField2() {
        return this.filteredField2;
    }
    
    public void setFilteredField2(String filteredField) {
        this.filteredField2 = filteredField;
    }       
    
    public String getFilteredField3() {
        return this.filteredField3;
    }
    
    public void setFilteredField3(String filteredField) {
        this.filteredField3 = filteredField;
    }       
    
    public String getFilteredField4() {
        return this.filteredField4;
    }
    
    public void setFilteredField4(String filteredField) {
        this.filteredField4 = filteredField;
    }       
    
    public String getFilteredField5() {
        return this.filteredField5;
    }
    
    public void setFilteredField5(String filteredField) {
        this.filteredField5 = filteredField;
    }       
    
    public String getSelectedOperator1() {
        return this.selectedOperator1;
    }
    
    public void setSelectedOperator1(String selectedOperator) {
        this.selectedOperator1 = selectedOperator;
    }  
    
    public String getSelectedOperator2() {
        return this.selectedOperator2;
    }
    
    public void setSelectedOperator2(String selectedOperator) {
        this.selectedOperator2 = selectedOperator;
    }   
    
    public String getSelectedOperator3() {
        return this.selectedOperator3;
    }
    
    public void setSelectedOperator3(String selectedOperator) {
        this.selectedOperator3 = selectedOperator;
    }   
    
    public String getSelectedOperator4() {
        return this.selectedOperator4;
    }
    
    public void setSelectedOperator4(String selectedOperator) {
        this.selectedOperator4 = selectedOperator;
    }   
    
    public String getSelectedOperator5() {
        return this.selectedOperator5;
    }
    
    public void setSelectedOperator5(String selectedOperator) {
        this.selectedOperator5 = selectedOperator;
    }

    public String getComparisonValue1() {
        return this.comparisonValue1;
    }
    
    public void setComparisonValue1(String comparisonValue) {
        this.comparisonValue1 = comparisonValue;
    }

    public String getComparisonValue2() {
        return this.comparisonValue2;
    }
    
    public void setComparisonValue2(String comparisonValue) {
        this.comparisonValue2 = comparisonValue;
    }

    public String getComparisonValue3() {
        return this.comparisonValue3;
    }
    
    public void setComparisonValue3(String comparisonValue) {
        this.comparisonValue3 = comparisonValue;
    }

    public String getComparisonValue4() {
        return this.comparisonValue4;
    }
    
    public void setComparisonValue4(String comparisonValue) {
        this.comparisonValue4 = comparisonValue;
    }

    public String getComparisonValue5() {
        return this.comparisonValue5;
    }
    
    public void setComparisonValue5(String comparisonValue) {
        this.comparisonValue5 = comparisonValue;
    }
    
    public String getLogicalJoin1() {
        return this.logicalJoin1;
    }
    
    public void setLogicalJoin1(String logicalJoin) {
        this.logicalJoin1 = logicalJoin;
    }
    
    public String getLogicalJoin2() {
        return this.logicalJoin2;
    }
    
    public void setLogicalJoin2(String logicalJoin) {
        this.logicalJoin2 = logicalJoin;
    }
    
    public String getLogicalJoin3() {
        return this.logicalJoin3;
    }
    
    public void setLogicalJoin3(String logicalJoin) {
        this.logicalJoin3 = logicalJoin;
    }
    
    public String getLogicalJoin4() {
        return this.logicalJoin4;
    }
    
    public void setLogicalJoin4(String logicalJoin) {
        this.logicalJoin4 = logicalJoin;
    }
    
    public String getQueriedField1() {
    	return this.queriedField1;
    }
    
    public void setQueriedField1(String queriedField) {
    	this.queriedField1 = queriedField;
    }
    
    public String getQueriedField2() {
        return this.queriedField2;
    }
    
    public void setQueriedField2(String queriedField) {
        this.queriedField2 = queriedField;
    }
    
    public String getQueriedField3() {
        return this.queriedField3;
    }
    
    public void setQueriedField3(String queriedField) {
        this.queriedField3 = queriedField;
    }
    
    public String getQueriedField4() {
        return this.queriedField4;
    }
    
    public void setQueriedField4(String queriedField) {
        this.queriedField4 = queriedField;
    }
    
    public String getQueriedField5() {
        return this.queriedField5;
    }
    
    public void setQueriedField5(String queriedField) {
        this.queriedField5 = queriedField;
    }
    
    public String getUpdateField1() {
        return this.updateField1;
    }
    
    public void setUpdateField1(String updateField) {
        this.updateField1 = updateField;
    }
    
    public String getUpdateField2() {
        return this.updateField2;
    }
    
    public void setUpdateField2(String updateField) {
        this.updateField2 = updateField;
    }
    
    public String getUpdateField3() {
        return this.updateField3;
    }
    
    public void setUpdateField3(String updateField) {
        this.updateField3 = updateField;
    }
    
    public String getUpdateField4() {
        return this.updateField4;
    }
    
    public void setUpdateField4(String updateField) {
        this.updateField4 = updateField;
    }
    
    public String getUpdateField5() {
        return this.updateField5;
    }
    
    public void setUpdateField5(String updateField) {
        this.updateField5 = updateField;
    }
    
    public String getUpdateValue1() {
        return this.updateValue1;
    }
    
    public void setUpdateValue1(String updateValue) {
        this.updateValue1 = updateValue;
    }
    
    public String getUpdateValue2() {
        return this.updateValue2;
    }
    
    public void setUpdateValue2(String updateValue) {
        this.updateValue2 = updateValue;
    }
    
    public String getUpdateValue3() {
        return this.updateValue3;
    }
    
    public void setUpdateValue3(String updateValue) {
        this.updateValue3 = updateValue;
    }
    
    public String getUpdateValue4() {
        return this.updateValue4;
    }
    
    public void setUpdateValue4(String updateValue) {
        this.updateValue4 = updateValue;
    }
    
    public String getUpdateValue5() {
        return this.updateValue5;
    }
    
    public void setUpdateValue5(String updateValue) {
        this.updateValue5 = updateValue;
    }
    
    public boolean getShowUpdateButton() {
    	return this.showUpdateButton;
    }
    
    public String getRecordCountMessage() {
    	return this.recordCountMessage;
    }
    
    public String getUpdateMessage() {
       return this.updateMessage;   
    }
    

    public static List<String> getAllTypes() {
        if(allTypes == null || allTypes.size() == 0) {
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
            allTypes = new List<String>();
            allTypes.addAll(gd.keySet());
            allTypes.sort();
        }
        return allTypes;
    }
    
    
    // the methods used for the various lists and checkboxes from the apex page
    public List<SelectOption> getTypes() {
        return SelectOptionGenerator.getTypes(OptionsUtility.getShowLabels(selectedOptions));
    }
    
    public List<SelectOption> getConfigurationOptions() {
        return SelectOptionGenerator.getConfigurationOptions();  
    }
    
    public List<SelectOption> getFilterableFields() {
    	List<SelectOption> options = SelectOptionGenerator.getFields(this.selectedType, 
            OptionsUtility.getShowLabels(selectedOptions), true, true, false, false, fieldsMap, parentFieldsMap);
        if(options.size() == 1000) {
            options[0].setLabel(Constants.none + ' (Field list was truncated because over 1,000 options exist!)');	
        }
        return options;
    }
    
    public List<SelectOption> getLogicalJoins() {
        return SelectOptionGenerator.getLogicalJoins();
    }
    
    public List<SelectOption> getQueryableFields() {
    	return SelectOptionGenerator.getFields(this.selectedType,
    	   OptionsUtility.getShowLabels(selectedOptions), false, false, false, false, fieldsMap, parentFieldsMap);
    }
    
    public List<SelectOption> getUpdateableFields() {
        return SelectOptionGenerator.getFields(this.selectedType, 
            OptionsUtility.getShowLabels(selectedOptions), false, false, true, true, fieldsMap, null);
    }
    
    public List<SelectOption> getOperators1() {
        return SelectOptionGenerator.getOperators(fieldsMap, filteredField1);
    }
    
    public List<SelectOption> getOperators2() {
        return SelectOptionGenerator.getOperators(fieldsMap, filteredField2);
    }
    
    public List<SelectOption> getOperators3() {
        return SelectOptionGenerator.getOperators(fieldsMap, filteredField3);
    }
    
    public List<SelectOption> getOperators4() {
        return SelectOptionGenerator.getOperators(fieldsMap, filteredField4);
    }
    
    public List<SelectOption> getOperators5() {
        return SelectOptionGenerator.getOperators(fieldsMap, filteredField5);
    }
    
}