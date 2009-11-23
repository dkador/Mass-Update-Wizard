// this is the controller for the page that lets you run a saved configuration
public with sharing class ConfigurationRunResultsController {
	
	// this keeps track of the standard controller that the custom controller extensions use
	private ApexPages.StandardController stdController;
	// stores the message to report back to the user
	private String updateMessage;
	// stores the number of records this would find
	private String recordCountMessage;
	
	// controller is a custom extension
	public ConfigurationRunResultsController(ApexPages.StandardController stdController) {
		this.stdController = stdController;
		
		// store the configuration
		Configuration__c conf = getConfiguration();
		// figure out how many SelectValues exist on this config
		Integer selectValueCount = [select count() from SelectValue__c where configuration__c=:conf.id];
		// construct the query utility based on the selected type, the filter values, and the fields map
		QueryUtility queryUtil = getQueryUtility(conf, true);
		if(queryUtil == null) {
			this.updateMessage = Constants.runResultsNoFilterValuesErrorMessage;
		} else {
	        try {
	            Integer recordCount = queryUtil.getNumberOfRecords();
	            // set the appropriate update message based on the number of updated records
	            if(recordCount == 10000) {
	                recordCountMessage = Constants.tooManyMatchingRecordsErrorMessage;
	            } else if(recordCount == 0) {
	                recordCountMessage = Constants.noValuesUpdatedMessage;
	            } else {
	                // if the user didn't select and fields to display, let's just show how many match
	                if(selectValueCount == 0) {
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
	        } catch(System.QueryException e) {
	            updateMessage = Constants.getUnknownQueryProblemErrorMessage(e.getMessage());
	        }
		}
	}
	
	private Configuration__c getConfiguration() {
		// grab the configuration object with a query
		return [select id, type__c from configuration__c where id=:stdController.getId()];
	}
	
	private QueryUtility getQueryUtility(Configuration__c conf, boolean doSelect) {
		// store the selected type in a variable
		String selectedType = conf.type__c;
		// get the map that goes from string -> sobjectfield based on the chosen type
		Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(selectedType).getDescribe().fields.getMap();
		// also get the fields map for all supported parent sobject types
		Map<String, Map<String, Schema.SObjectField>> parentFieldsMap = DescribeUtility.getParentFieldDescribeMaps(fieldsMap);
		// build a list of filter values
		List<FilterValue> filterValues = new List<FilterValue>();
		// build a list of select values
		List<String> selectValues = null;
		if(doSelect) {
			selectValues = new List<String>();
			// iterate over all the configuration's select values and add them to the list
			for(SelectValue__c sv : [select id, fieldname__c from selectvalue__c where configuration__c=:conf.id]) {
				selectValues.add(sv.fieldname__c);
			}
		}
		// iterate over all the configuration's filter values and add them to the list
		for(FilterValue__c fv : [select id, fieldname__c, operator__c, filtervalue__c, logicaljoin__c from filtervalue__c where configuration__c=:conf.id order by name]) {
			filterValues = FilterValue.addFilterValueToList(fv.fieldname__c, fv.operator__c, fv.filtervalue__c, fv.logicaljoin__c, filterValues);
		}
		// if the list is empty, then we can't do anything, so set the error message and return
		if(filterValues.size() == 0) {
			updateMessage = Constants.runResultsNoFilterValuesErrorMessage;
			return null;
		}
		// construct the query utility based on the selected type, the filter values, and the fields map
		return new QueryUtility(selectValues, selectedType, filterValues, fieldsMap, parentFieldsMap);
	}
	
	// this action does the updates
	public PageReference doUpdate() {
		// grab the configuration object with a query
		Configuration__c conf = getConfiguration();
		// store the selected type in a variable
		String selectedType = conf.type__c;
		// construct the query utility based on the selected type, the filter values, and the fields map
		QueryUtility queryUtil = getQueryUtility(conf, false);
		// build a list of update values
		List<UpdateValue> updateValues = new List<UpdateValue>();
		// iterate over all the configuration's update values and add them to the list
		for(UpdateValue__c uv : [select id, fieldname__c, fieldvalue__c from updatevalue__c where configuration__c=:conf.Id]) {
			updateValues = UpdateValue.addUpdateValueToList(uv.fieldname__c, uv.fieldvalue__c, updateValues);
		}
		// if the list is empty, then we can't do anything, so set the error message and return
		if(updateValues.size() == 0) {
			updateMessage = Constants.runResultsNoUpdateValuesErrorMessage;
			return null;
		}
		// get the map that goes from string -> sobjectfield based on the chosen type
		Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(selectedType).getDescribe().fields.getMap();
		// construct the update utility based on the query utility, update values, and the fields map
		UpdateUtility updateUtil = new UpdateUtility(queryUtil, updateValues, fieldsMap);
		// do the update!
		integer recordCount = updateUtil.updateRecords();
		if(recordCount == 0) {
			// no records were found :(
            updateMessage = Constants.noValuesUpdatedMessage; 
		} else if(recordCount > 10000) {
			// too many records were found! :(
			updateMessage = Constants.tooManyMatchingRecordsErrorMessage;
		} else {
			// awesome, we did the update, here are how many you updated
            updateMessage = Constants.getSuccessfulUpdateMessage(recordCount);
		}
		// return nothing - we don't want a redirect
		return null;
	}
	
	// used by the apex page to get the update message
	public String getUpdateMessage() {
		return this.updateMessage;
	}
	
	public String getRecordCountMessage() {
		return this.recordCountMessage;
	}
	
}