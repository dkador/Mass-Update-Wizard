public class UpdateValue {
    
    private String fieldName;
    private String fieldValue;
    
    public UpdateValue(String fieldName, String fieldValue) {
        if(fieldName == null || fieldName.equals(Constants.none)) {
            throw new MUWException('The update value\'s field name must be specified!');
        } 
        if(fieldValue == null) {
            throw new MUWException('The update value\'s field value must be specified!');
        }
        this.fieldName = String.escapeSingleQuotes(fieldName);
        this.fieldValue = String.escapeSingleQuotes(fieldValue);
    }
    
    public String getFieldName() {
        return this.fieldName;
    }
    
    public String getFieldValue() {
        return this.fieldValue;
    }
    
    public static UpdateValue buildUpdateValue(String fieldName, String fieldValue) {
        if(Constants.none.equals(fieldName) && ''.equals(fieldValue)) {
            return null;
        }
        return new UpdateValue(fieldName, fieldValue);
    }
    
    public static List<UpdateValue> addUpdateValueToList(String fieldName, String fieldValue,
                  List<UpdateValue> values) {
        UpdateValue value = buildUpdateValue(fieldName, fieldValue);
        if(value != null) {
            values.add(value);
        }
        return values;
    }
    
}