public class QueryUtility {

    private String[] selectedFields;
    private String selectedType;
    private FilterValue[] filterValues;
    private Map<String, Schema.SObjectField> fieldsMap;
    private Map<String, Map<String, Schema.SObjectField>> parentFieldsMap;

    public QueryUtility(String[] selectedFields, String selectedType, FilterValue[] filterValues,
            Map<String, Schema.SObjectField> fieldsMap,
            Map<String, Map<String, Schema.SObjectField>> parentFieldsMap) {
        if(selectedType == null || Constants.none.equals(selectedType)) {
            throw new MUWException('selectedType cannot be null or not-selected!');
        }
        if(fieldsMap == null) {
            throw new MUWException('fieldsMap cannot be null!');
        }
        this.selectedFields = selectedFields;
        this.selectedType = String.escapeSingleQuotes(selectedType);
        this.filterValues = filterValues;
        this.fieldsMap = fieldsMap;
        this.parentFieldsMap = parentFieldsMap;
    }
    
    public Integer getNumberOfRecords() {
    	String countQuery = generateQuery(true);
    	return Database.countQuery(countQuery);	
    }
    
    public String getTableHtml() {
    	// setup the initial table html
    	String html = '' +
            '<table class="tableClass" cellspacing="5" cellpadding="3" rules="all"><thead>' + 
            '<tr><th>Index</th>';
        // iterate over the selected fields to display to the user so we can setup the column headers 
        for(String selectedField : selectedFields) {
        	// get whether or not the field is a relationship field
        	FieldNameAndDescribePair pair = determineWhetherRelationshipField(selectedField, fieldsMap);
        	String label = null;
        	// if this isn't null, then there's a relationship involved
        	if(pair.getSObjectType() != null) {
        		Schema.DescribeFieldResult childFieldResult = null;
        		System.debug('pair sobjecttype: ' + pair.getSObjectType());
        		// iterate through the fields in the child object and look for the field matching this relationship name
        		for(Schema.SObjectField field : fieldsMap.values()) {
        			String realRelationshipName = null;
        			if(field.getDescribe() != null) {
        				realRelationshipName = field.getDescribe().getRelationshipName();
        				/*if(realRelationshipName != null && realRelationshipName.startswith('muw__')) {
        					realRelationshipName = realRelationshipName.substring(5);
        				}*/
        			}
        			// found it
        			if(pair.getSObjectType().equals(realRelationshipName)) {
        				childFieldResult = field.getDescribe();
        			}
        		}	
        		Schema.DescribeFieldResult parentFieldResult = pair.getFieldsMap().get(pair.getFieldName()).getDescribe();
        		label = 'Parent ' + childFieldResult.getReferenceTo()[0] + ' (' + childFieldResult.getRelationshipName() + '): ' + parentFieldResult.getLabel();
        	} else {
        		System.debug('pair field name: ' + pair.getFieldName());
        		System.debug('pair fields map: ' + pair.getFieldsMap());
        		Schema.SObjectField field = pair.getFieldsMap().get(pair.getFieldName());
        		System.debug('field: ' + field);
        		Schema.DescribeFieldResult describe = field.getDescribe();
        		label = describe.getLabel();
        	}
        	// add the label to the row
            html += '<th>' + label + '</th>';
        }
        html += '</tr></thead><tbody>';
        Integer count = 1;
        // this chunks up the records in appropriate batch sizes for the DML
        for(List<SObject> objs : Database.query(generateQuery(false, false))) {
        	// iterate over the matching objects
            for(SObject obj : objs) {
            	String rowClass = 'odd';
            	if(Math.mod(count, 2) == 0) {
            		rowClass = 'even';
            	}
                html += '<tr class="' + rowClass + '">';
                html += '<td>' + count + '</td>';
                count++;
            	// iterate over the selected fields
            	for(String selectedField : selectedFields) {
            		// figure out whether the selected field is a relationship
                    FieldNameAndDescribePair pair = determineWhetherRelationshipField(selectedField, fieldsMap);
                    String fieldName = pair.getFieldName();
                    // store the queried value in an object for later use
                    Object val = null;
                    // if this isn't null, then it was a relationship field
                    if(pair.getSObjectType() != null) {
                    	// grab the parent object
                    	SObject parentObj = obj.getSObject(pair.getSObjectType());
                    	// it may not exist, so check for null
                    	if(parentObj != null) {
                    	    // store the actual field value	
                    	    val = parentObj.get(fieldName);
                    	}
                    } else {
                    	// just get the field value from the base object
                    	val = obj.get(fieldName);
                    }
                    // add the value to the row
            		html += '<td>' + val + '</td>';
            	}
            	html += '</tr>';
            }
        }
        html += '</tbody></table>';
        return html;
    }
    
    public String generateQuery(boolean findCount) {
    	return generateQuery(findCount, !findCount);
    }
    
    public String generateQuery(boolean findCount, boolean selectForUpdate) {
        String queryString = 'select ';
        if(findCount) {
            queryString += 'count()';
        } else {
            if(selectedFields != null && selectedFields.size() > 0) {
                integer count = 0;
                boolean idSelected = false;
                for(String selectedField : selectedFields) {
                    if(selectedField.equalsIgnoreCase('id')) {
                        idSelected = true;
                    }
                    if(count > 0) {
                        queryString += ', ';
                    }
                    queryString += selectedField;
                    count++;
                }   
                // add the id field if it's not part of the selected fields
                if(!idSelected) {
                    queryString += ', id';
                }
            } else {
                queryString += 'id';
            }
        }
        queryString += ' from ' + selectedType + ' where ';
        for(integer i=0; i<filterValues.size(); i++) {
            String fieldName = filterValues[i].getFieldName();
            // this might be a parent field, so let's check
            FieldNameAndDescribePair pair = determineWhetherRelationshipField(fieldName, fieldsMap);
            String realFieldName = pair.getFieldName();
            Map<String, SObjectField> fieldsMap = pair.getFieldsMap();
            String operator = filterValues[i].getOperator();
            String fieldValue = filterValues[i].getFieldValue();
            String valueEnclosure = getValueEnclosure(realFieldName, fieldsMap);
            queryString += '(';
            if(operator.equals('startswith')) {
            	queryString += fieldName + ' like ' + valueEnclosure + fieldValue + '%' + valueEnclosure;
            } else if(operator.equals('contains')) {
            	queryString += fieldName + ' like ' + valueEnclosure + '%' + fieldValue + '%' + valueEnclosure; 
            } else if(operator.equals('doesnotcontain')) {
            	queryString += ' NOT ' + fieldName + ' like ' + valueEnclosure + '%' + fieldValue + '%' + valueEnclosure; 
            } else if(operator.equals('in') || operator.equals('not in') || operator.equals('includes') || operator.equals('excludes')) {
            	queryString += fieldName + ' ' + operator + ' (' + valueEnclosure + fieldValue + valueEnclosure + ')';
            } else {
                queryString += fieldName + ' ' + operator + ' ' + valueEnclosure + fieldValue + valueEnclosure;
            }
            queryString += ')';
            if(i != filterValues.size() - 1) {
            	String logicalJoin = filterValues[i].getLogicalJoin();
                queryString += ' ' + logicalJoin + ' ';
            }   
        }
        // have to limit ourselves to 10,000 because there's an apex bug that doesn't let me catch the
        // exception that's thrown when a query returns a record set > 10,000 rows (even during a count()
        // query!!)
        queryString += ' limit 10000';
        // lock the records when we're about to do an update on them
        if(selectForUpdate) {
           queryString += ' for update';
        }
        System.debug('generated query string: ' + queryString);
        return queryString;
    }
    
    private FieldNameAndDescribePair determineWhetherRelationshipField(String fieldName, Map<String, Schema.SObjectField> fieldsMap) {
    	// this might be a parent field, so let's check
        String[] fieldNameParts = fieldName.split('\\.');
        if(fieldNameParts.size() != 1 && fieldNameParts.size() != 2) {
            throw new MUWException(fieldName + ' is not a valid field name!');
        }
    	String realFieldName = fieldName;
    	// make a copy so we don't change the reference
    	Map<String, Schema.SObjectField> realFieldsMap = fieldsMap;
    	FieldNameAndDescribePair pair = new FieldNameAndDescribePair(realFieldName, null, realFieldsMap);
        if(fieldNameParts.size() == 2) {
            // we have to find which object the field refers to since it's a parent field
            String relationshipName = fieldNameParts[0];
            realFieldName = fieldNameParts[1];
            for(Schema.SObjectField field : realFieldsMap.values()) {
                Schema.DescribeFieldResult fieldResult = field.getDescribe();
                String realRelationshipName = fieldResult.getRelationshipName();
		        /*if(realRelationshipName != null && realRelationshipName.startsWith('muw__')) {
		            realRelationshipName = realRelationshipName.substring(5);
		        }*/
                if(relationshipName.equals(realRelationshipName)) {
                    List<Schema.SObjectType> references = fieldResult.getReferenceTo();
                    pair = new FieldNameAndDescribePair(realFieldName, fieldNameParts[0], parentFieldsMap.get(references[0].getDescribe().getLocalName()));
                    break;
                    // TODO: support name denorm
                }
            }
        }
        return pair;
    }
    
    private String getValueEnclosure(String fieldName, Map<String, Schema.SObjectField> fieldsMap) {
    	System.debug('fieldsMap: ' + fieldsMap);
    	System.debug('fieldName: ' + fieldName);
        Schema.DescribeFieldResult result = fieldsMap.get(fieldName).getDescribe();
        String valueEnclosure = '\'';
        if(result.getType() == DisplayType.Boolean ||
           result.getType() == DisplayType.Currency ||
           result.getType() == DisplayType.Date ||
           result.getType() == DisplayType.DateTime ||
           result.getType() == DisplayType.Time ||
           result.getType() == DisplayType.Double ||
           result.getType() == DisplayType.Integer) {
           valueEnclosure = '';
        }
        return valueEnclosure;
    }
    
    class FieldNameAndDescribePair {
    	
    	private String fieldName;
    	private String sObjectType;
    	private Map<String, Schema.SObjectField> fieldsMap;
    	
    	FieldNameAndDescribePair(String fieldName, String sObjectType, Map<String, Schema.SObjectField> fieldsMap) {
    		this.fieldName = fieldName;
    		this.sObjectType = sObjectType;
    		this.fieldsMap = fieldsMap;
    	}
    	
    	String getFieldName() {
    		return this.fieldName;
    	}
    	
    	String getSObjectType() {
    		return this.sObjectType;
    	}
    	
    	Map<String, Schema.SObjectField> getFieldsMap() {
    		return this.fieldsMap;
    	}
    	
    }
    
}