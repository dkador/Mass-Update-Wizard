public class UpdateUtility {

    private QueryUtility queryUtil;
    private List<UpdateValue> updateValues;
    private Map<String, Schema.SObjectField> fieldsMap;
    
    public UpdateUtility(QueryUtility queryUtil,
                            List<UpdateValue> updateValues,
                            Map<String, Schema.SObjectField> fieldsMap) {
        if(queryUtil == null) {
            throw new MUWException('queryUtil cannot be null!');
        }
        if(updateValues == null) {
            throw new MUWException('updateValues cannot be null!');
        }
        if(fieldsMap == null) {
            throw new MUWException('fieldsMap cannot be null!');
        }
        this.queryUtil = queryUtil;
        this.updateValues = updateValues;
        this.fieldsMap = fieldsMap;
    }
    
    // if there are more than 10000 records, we can't do anything because of limitations
    // in async apex (can't take in non-primitive types and we need to pass in the describe)
    public integer updateRecords() {
        // find how many records we're going to update
        String countQuery = queryUtil.generateQuery(true);
        integer recordCount = Database.countQuery(countQuery);
        if(recordCount > 10000) {
            // you can't do that, return the record count and let the controller handle it
            // (i.e. do nothing)
        } else if(recordCount == 0) {
            // do nothing
        } else {
            // this chunks up the records in appropriate batch sizes for the DML
            for(List<SObject> objs : Database.query(queryUtil.generateQuery(false))) {
                for(SObject obj : objs) {
                    for(UpdateValue value : updateValues) {
                        obj.put(value.getFieldName(), getTypedFieldValue(value));   
                    }
                }   
                update objs;
            }
        }
        return recordCount;
    }
    
    // this should be private but I'm making it public so I can test it
    public Object getTypedFieldValue(UpdateValue value) {
        String fieldName = value.getFieldName();
        String fieldValue = value.getFieldValue();
        Schema.SObjectField f = fieldsMap.get(fieldName);
        DescribeFieldResult result = f.getDescribe();
        DisplayType fieldType = result.getType();
        Object retVal = fieldValue;
        if(fieldType == DisplayType.Boolean) {
            retVal = 'true'.equalsIgnoreCase(fieldValue) ? true : false;
        } else if(fieldType == DisplayType.Currency || fieldType == DisplayType.Double || fieldType == DisplayType.Percent) {
            retVal = Double.valueOf(fieldValue);
        } else if(fieldType == DisplayType.Date) {
            retVal = Date.valueOf(fieldValue);
        } else if(fieldType == DisplayType.DateTime) {
            retVal = DateTime.valueOf(fieldValue);
        // don't know how to test an integer :(
        } else if(fieldType == DisplayType.Integer) {
            retVal = Integer.valueOf(fieldValue);
        // can't test this right now since we can't create a custom time object and
        // I don't want to test on a standard object that might not be available
        } else if(fieldType == DisplayType.Time) {
        	// this is so stupid why doesn't apex have a static valueOf method for Time?
        	String[] splitArr = fieldValue.split(':');
        	if(splitArr.size() != 4) {
        		throw new MUWException('Incorrect format for time!');
        	}
        	Integer hour = Integer.valueOf(splitArr[0]);
        	Integer minute = Integer.valueOf(splitArr[1]);
        	Integer second = Integer.valueOf(splitArr[2]);
        	Integer millisecond = Integer.valueOf(splitArr[3]);
        	retVal = Time.newInstance(hour, minute, second, millisecond);
        } else if(fieldType == DisplayType.Reference) {
        	ID id = fieldValue;
        	retVal = id;
        }
        return retVal;
    }

}