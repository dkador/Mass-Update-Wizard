// this is used to keep track of static internal strings and messages for the user
public class Constants {

    public static final String none = '--None--';
    public static final String showLabels = 'showLabels';
    public static final String showParentFields = 'showParentFields';
    
    public static final String invalidObjectTypeErrorMessage = 'SObject Type: The type you selected is not a valid type or cannot be updated!';
    public static final String noObjectTypeErrorMessage = 'You need to select an object type!';
    public static final String noFiltersErrorMessage = 'You did not specify any filter values!';
    public static final String noUpdateValuesErrorMessage = 'You did not specify any update values!';
    public static final String tooManyMatchingRecordsErrorMessage = 'There are too many matching records! Please restrict your data set further by setting more filter values.';
    
    public static final String tooManyFilterValuesErrorMessage = 'Each configuration option can have only 50 filter values!';
    public static final String filterValueIncorrectFieldNameErrorMessage = 'Field Name: You must select a valid value!';
    public static final String filterValueIncorrectOperatorErrorMessage = 'Operator: You must select a valid value!';
    public static final String filterValueIncorrectLogicalJoinErrorMessage = 'Logical Join: You must specify either "and" or "or"!';
    public static final String tooManyUpdateValuesErrorMessage = 'Each configuration option can have only 50 filter values!';
    public static final String updateValueIncorrectFieldNameErrorMessage = 'Field Name: You must select a valid value!';
    public static final String updateValueDuplicateFieldNameErrorMessage = 'Field Name: There is already an update value on this configuration for the chosen field name!';
    
    public static final String runResultsNoFilterValuesErrorMessage = 'This configuration has no filter values.  Please add a filter value before performing an update!';
    public static final String runResultsNoUpdateValuesErrorMessage = 'This configuration has no update values.  Please add an update value before performing an update!';
    
    public static final String unknownQueryProblemErrorMessage = 'A problem exists with your query!  Please view the following message returned from salesforce: ';
    public static String getUnknownQueryProblemErrorMessage(String message) {
    	return unknownQueryProblemErrorMessage + '"' + message + '"';
    }
    
    public static String getSuccessfulUpdateMessage(integer count) {
    	return 'You have successfully updated ' + count + ' matching record(s)!';
    }
    public static final String noValuesUpdatedMessage = 'No matching records found!';   
    
    public static String getExceptionErrorMessage(String message) {
    	return 'There was a problem executing the action with your specified selections! The error is: ' + message; 
    }  
    
}