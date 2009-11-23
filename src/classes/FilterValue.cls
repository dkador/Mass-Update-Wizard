// this is an internal representation of what a filter value should be
public class FilterValue {

    // the name of the field to filter on
    private String fieldName;
    // the kind of filter we're doing
    private String operator;
    // the value the field should/should not be
    private String fieldValue;
    // and/or join with the next filter value
    private String logicalJoin;

    // constructor that sets the logical join to AND
    public FilterValue(String fieldName, String operator, String fieldValue) {
    	this(fieldName, operator, fieldValue, 'AND');
    }

    // main constructor
    public FilterValue(String fieldName, String operator, String fieldValue, String logicalJoin) {
    	// throw an exception if fieldname is null or not selected
        if(fieldName == null || fieldName.equals(Constants.none)) {
            throw new MUWException('The filter criteria\'s field name must be specified!');
        }
        // throw an exception if operator is null or not selected
        if(operator == null || operator.equals(Constants.none)) {
            throw new MUWException('The filter criteria\'s operator must be specified!');
        }
        // throw an exception if fieldValue is null or not selected
        if(fieldValue == null) {
            throw new MUWException('The filter criteria\'s field value must be specified!');
        }
        this.fieldName = String.escapeSingleQuotes(fieldName);
        this.operator = String.escapeSingleQuotes(operator);
        this.fieldValue = String.escapeSingleQuotes(fieldValue);
        this.logicalJoin = logicalJoin == null ? null : String.escapeSingleQuotes(logicalJoin);   
    }
    
    // get the field name
    public String getFieldName() {
        return this.fieldName;
    }
    
    // get the operator
    public String getOperator() {
        return this.operator;
    }
    
    // get the field name
    public String getFieldValue() {
        return this.fieldValue;
    }
    
    // get the logical join
    public String getLogicalJoin() {
    	return this.logicalJoin;
    }
    
    // used to build a filter value. returns null if the user hasn't selected anything yet.
    public static FilterValue buildFilterValue(String fieldName, String operator, String fieldValue, String logicalJoin) {
        // this represents when a user doesn't have any input for this option, so we can just return
        // null instead of erroring
        if(Constants.none.equals(fieldName) && Constants.none.equals(operator) &&
           ''.equals(fieldValue)) {
            return null;
        }
        return new FilterValue(fieldName, operator, fieldValue, logicalJoin);
    }
    
    // adds a new filter value to an existing list of them
    public static List<FilterValue> addFilterValueToList(String fieldName, String operator,
                  String fieldValue, String logicalJoin, List<FilterValue> values) {
        FilterValue value = buildFilterValue(fieldName, operator, fieldValue, logicalJoin);
        if(value != null) {
            values.add(value);
        }
        return values;
    }

}