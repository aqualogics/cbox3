/**
* I am the LoadXMLschema Model Object.
*/
component singleton accessors="true" {
	
	// I generate a structure used as input to initiate Data Access Objects (DAOs) with schema data

	public struct function schemaDataDAO(required string fieldNamesPath, 
										 required string tableNamePath,
									  	 required string primaryKeyPath, 
										 string secondaryKeyPath, 
										 required string sortIndexPath ) {

		var xmlObject = "";
		var fieldNameList = "";
		var tableName="";
		var primaryKeyName="";									  
		var secondaryKeyName ="";
		var defaultOrderBy="";

		// Load the schema
		xmlObject = XmlParse("/models/xml/schema.xml",true);

		// Build an array containing the table field names

		if (len(arguments.fieldNamesPath)) {

		var arrayFieldNames = arrayNew(1);
		arrayFieldNames = XmlSearch(xmlObject, arguments.fieldNamesPath);
		for (i = 1; i LTE ArrayLen(arrayFieldNames); i++) {		
			fieldNameList = fieldNameList.listAppend(arrayFieldNames[i].XmlValue); 
			}

		}

		// Build an array containing the table name

		if (len(arguments.tableNamePath)) {

		var arrayTableName = arrayNew(1);
		arrayTableName = XmlSearch(xmlObject, arguments.tableNamePath);
		tableName = tableName.listAppend(arrayTableName[1].XmlValue);

		}

		// Build an array containing the primary key

		if (len(arguments.primaryKeyPath)) {

		var arrayPrimaryKeyName = arrayNew(1);
		arrayPrimaryKeyName = XmlSearch(xmlObject, arguments.primaryKeyPath);
		primaryKeyName = primaryKeyName.listAppend(arrayPrimaryKeyName[1].XmlValue);

		}
		
		// Build an array containing an optional secondary key if its XML path is not blank

		if (len(arguments.secondaryKeyPath)) {

		var arraySecondaryKeyName = arrayNew(1);
		arraySecondaryKeyName = XmlSearch(xmlObject,"#arguments.secondaryKeyPath#");
		secondaryKeyName = secondaryKeyName.listAppend(arraySecondaryKeyName[1].XmlValue);

		}

		// Build an array containing the default sort index

		if (len(arguments.sortIndexPath)) {

		var arrayDefaultOrderBy = arrayNew(1);
		arrayDefaultOrderBy = XmlSearch(xmlObject,"#arguments.sortIndexPath#");
		defaultOrderBy = defaultOrderBy.listAppend(arrayDefaultOrderBy[1].XmlValue);

		}

		// Then, build a structure containing the schema to be passed to the BaseDAO component

		var schemaDataDAO = StructNew();
			schemaDataDAO.fieldNameList = "#fieldNameList#"
			schemaDataDAO.tableName = "#tableName#"
			schemaDataDAO.primaryKeyName = "#primaryKeyName#"
			schemaDataDAO.secondaryKeyName = "#secondaryKeyName#"
			schemaDataDAO.defaultOrderBy = "#defaultOrderBy#"

	return schemaDataDAO;											  

	}

}