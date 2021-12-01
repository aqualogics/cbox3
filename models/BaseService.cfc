//  Filename:    BaseService.cfc
//  Location: 	 /models/BaseService.cfc
//  Created by:  Philippe Sambor
//  Purpose:     Implements the Base service object as the parent of all services.

component displayname="BaseService" accessors="true"
		  hint="I am the BaseService class, a template schema mapper for children services classes." {

	// global properties

	property name="entityName";
	property name="serviceName";
	property name="moduleName";

	// Dependency injection

	property name="dsn" inject="coldbox:setting:cbox3";
	property name="LoadXMLschema" inject="LoadXMLschema";
	property name="wirebox" inject="wirebox";
	property name="populator" inject="wirebox:populator";

	// BASE SERVICE INITIALIZATION FUNCTIONS

	/**
	 * Initialize the BaseService with the values passed by the children components
	 *
	 * @entityName The name of the entity so we can reference it for calls to related DAO and Service. Set as optional for backwards
	 * @serviceName The name of the service that manages the entity
	 * @moduleName The name of the module for the objects
	 * @fieldNamesPath an Xpath method returning the field names of a table from an XML schema
	 * @tableNamePath an Xpath method returning the name of a table from an XML schema
	 * @primaryKeyPath an Xpath method returning the name of the primary key from the table
	 * @secondaryKeyPath an Xpath method returning the name of an optional composite's secondary key
	 * @sortindexPath an Xpath method returning the name of an index key used for sorting
	 */

	public any function init(required string entityName,
							 required string serviceName,
							 required string moduleName,
							 required string fieldNamesPath,
							 required string tableNamePath,
							 required string primaryKeyPath,
							 required string secondaryKeyPath,
							 required string sortIndexPath) {

	// Set the values passed from the child components init function

	variables.entityName = arguments.entityName;
	variables.serviceName = arguments.serviceName;
	variables.moduleName = arguments.moduleName;
	variables.fieldNamesPath = arguments.fieldNamesPath;
	variables.tableNamePath = arguments.tableNamePath;
	variables.primaryKeyPath = arguments.primaryKeyPath;
	variables.secondaryKeyPath = arguments.secondaryKeyPath;
	variables.sortIndexPath = arguments.sortIndexPath;

	// Set the entity, service and associated module name

	setEntityName( arguments.entityName );

	if ( arguments.serviceName != "" ) {
			setServiceName( arguments.serviceName );
		} else {
			setServiceName( arguments.entityName & "Service" );
		}

	setModuleName( arguments.moduleName );

	if ( arguments.moduleName != "" ) {
		setServiceName( getServiceName() & "@" & arguments.moduleName );
	}

	return this;						 

	}

	struct function subsetArgs() {

	// I build and return a structure containing schema and entity attributes	

	var schemaDAO = StructNew();
		schemaDAO = LoadXMLSchema.schemaDataDAO(variables.fieldNamesPath,
												variables.tableNamePath,
												variables.primaryKeyPath,
												variables.secondaryKeyPath,
												variables.sortIndexPath);										

	var subsetArgs = structNew();
	subsetArgs.entityName = getEntityName();
	subsetArgs.fieldNames = schemaDAO.fieldNameList;
	subsetArgs.tableName = schemaDAO.tableName;
	subsetArgs.primaryKey = schemaDAO.primaryKeyName;
	subsetArgs.secondaryKey = schemaDAO.secondaryKeyName;
	subsetArgs.defaultOrderBy = schemaDAO.defaultOrderBy;
	subsetArgs.serviceName = getServiceName();
	subsetArgs.moduleName = getModuleName();

	return subsetArgs;

	}
	
	// READ RECORD IDENTIFIED BY NUMERIC ID

	public query function getByID(required ID){

		var args = subsetArgs();
		
		try {

			var params = {
	        	key: { value: arguments.ID, cfsqltype: "numeric" }
	    	};

	    	var sql = "SELECT #args.fieldNames# FROM #args.tableName#  WHERE #args.primaryKey# = :key";
			var qData = queryExecute( sql, params, { datasource: dsn.name } );

		} catch (database e) {

			// Build the error message and capture it to a variable
	
			var errorMsg = "#e.sqlState#: #e.message# #e.queryError#";
	
			// Throw the exception and pass the error message variable for the controller to handle
	
			throw(type="DBreadError", message="#errorMsg#"); 
	
		} 

		return qData;

	}

	// READ RECORD IDENTIFIED BY A CODE (Fixed length string)

	public query function getByCD(required string CD) {

		var args = subsetArgs();	
		
		try {

			var params = {
				key: { value: arguments.CD, cfsqltype: "string" }
			};
			
			var sql = "SELECT #args.fieldNames# FROM #args.tableName#  WHERE #args.primaryKey# = :key";
			var qData = queryExecute( sql, params, { datasource: dsn.name } );		

			} catch (database e) {

			// Build the error message and capture it to a variable

			var errorMsg = "#e.sqlState#: #e.message# #e.queryError#";

			// Throw the exception and pass the error message variable for the controller to handle

			throw(type="DBreadError", message="#errorMsg#"); 

		}
		
		return qData;

	}

	// READ RECORD IDENTIFIED BY COMPOSITE NUMERIC IDs
	
	public query function getByCompositeID(required ID1, required ID2) {

		var args = subsetArgs();	

		try {

			var params = {
				key1: { value: arguments.ID1, cfsqltype: "numeric" },
				key2: { value: arguments.ID2, cfsqltype: "numeric" }
			};

			var sql = "SELECT #args.fieldNames# FROM #args.tableName#  
					WHERE #args.primaryKey# = :key1
					AND #args.secondaryKey# = :key2";

			var qData = queryExecute( sql, params, { datasource: dsn.name } );

			}	catch (database e) {

			// Build the error message and capture it to a variable

			var errorMsg = "#e.sqlState#: #e.message# #e.queryError#";

			// Throw the exception and pass the error message variable for the controller to handle

			throw(type="DBreadError", message="#errorMsg#"); 

		}
		
		return qData;

	}

	// READ RECORD IDENTIFIED BY A NAME (Variable length string)

	public query function getByName(required string Name) {

		var args = subsetArgs();	
		
		try {

			var params = {
				key: { value: arguments.Name, cfsqltype: "string" }
			};

			var sql = "SELECT #args.fieldNames# FROM #args.tableName#  WHERE #args.primaryKey# = :key";
			
			var qData = queryExecute( sql, params, { datasource: dsn.name } );		

			} catch (database e) {

			// Build the error message and capture it to a variable

			var errorMsg = "#e.sqlState#: #e.message# #e.queryError#";

			// Throw the exception and pass the error message variable for the controller to handle

			throw(type="DBreadError", message="#errorMsg#"); 

		}
		
		return qData;

	}

	// CREATE & UPDATE methods are found in the children objects that inherit this base class.

	// DELETE RECORD IDENTIFIED BY A NUMERIC ID

	public boolean function deleteByID(required numeric ID) {

		var args = subsetArgs();	
		var boolSuccess = true;
		
		try {

			var params = {
				key: { value: arguments.ID, cfsqltype: "numeric" }
			};

			var sql = "DELETE FROM #args.tableName#  WHERE #args.primaryKey# = :key";

			queryExecute( sql, params, { datasource: dsn.name } );	

			} catch (database e) {

			// Build the error message and capture it to a variable

			var errorMsg = "#e.sqlState#: #e.message# #e.queryError#";

			// Throw the exception and pass the error message variable for the controller to handle

			throw(type="DBdeleteError", message="#errorMsg#");
			boolSuccess = false; 

		}

		return boolSuccess;		

	}

	// DELETE RECORD IDENTIFIED BY A CODE (Fixed length string)

	public boolean function deleteByCD(required string CD) {

		var args = subsetArgs();	
		var boolSuccess = true;

		try {

			var params = {
				key: { value: arguments.CD, cfsqltype: "string" }
			};

			var sql = "DELETE FROM #args.tableName#  WHERE #args.primaryKey# = :key";

			queryExecute( sql, params, { datasource: dsn.name } );		
		
			} catch (database e) {

			// Build the error message and capture it to a variable

			var errorMsg = "#e.sqlState#: #e.message# #e.queryError#";

			// Throw the exception and pass the error message variable for the controller to handle

			throw(type="DBdeleteError", message="#errorMsg#");
			boolSuccess = false; 

		}

	return boolSuccess;		

	}

	// DELETE RECORD IDENTIFIED BY COMPOSITE NUMERIC IDs

	public boolean function deleteByCompositeID(required numeric ID1, required numeric ID2) {

		var args = subsetArgs();	
		var boolSuccess = true;
		
		try {

			var params = {
				key1: { value: arguments.ID1, cfsqltype: "numeric" },
				key2: { value: arguments.ID2, cfsqltype: "numeric" }
			};

			var sql = "DELETE FROM #args.tableName#  
					   WHERE #args.primaryKey# = :key1
					   AND #args.secondaryKey# = :key2";

			queryExecute( sql, params, { datasource: dsn.name } );	

		} catch (database e) {

		// Build the error message and capture it to a variable

		var errorMsg = "#e.sqlState#: #e.message# #e.queryError#";

		// Throw the exception and pass the error message variable for the controller to handle

		throw(type="DBdeleteError", message="#errorMsg#");
		boolSuccess = false; 

		}

	return boolSuccess;		

	}

	// DELETE RECORD IDENTIFIED BY A NAME (Variable length string)

	public boolean function deleteByName(required string Name) {
 
		var args = subsetArgs();	
		var boolSuccess = true;

		try {

			var params = {
				key: { value: arguments.Name, cfsqltype: "string" }
			};

			var sql = "DELETE FROM #args.tableName#  WHERE #args.primaryKey# = :key";

			queryExecute( sql, params, { datasource: dsn.name } );		

		} catch (database e) {

			// Build the error message and capture it to a variable

			var errorMsg = "#e.sqlState#: #e.message# #e.queryError#";

			// Throw the exception and pass the error message variable for the controller to handle

			throw(type="DBdeleteError", message="#errorMsg#");
			boolSuccess = false; 

			}

		return boolSuccess;		

	}

// GATEWAY METHODS

	public query function getAllRecords() {

	var args = subsetArgs(); 	

	// Execute the query to return all records

	try {

		var sql = "SELECT * FROM #args.tableName# ORDER BY #args.defaultOrderBy#";
	    var qData = queryExecute( sql, {}, { datasource: dsn.name } );

		} catch (database e) {

			// Build the error message and capture it to a variable

			var errorMsg = "#e.sqlState#: #e.message# #e.queryError#";

			// Throw the exception and pass the error message variable for the controller to handle

			throw(type="DBgwError", message="#errorMsg#"); 

		}

		return qData;

	}

	public query function getByFilter(required struct stuFilter) {

	var args = subsetArgs(); 										  		

	// Retrieve the filter values and map them to the search query

	var valueField = arguments.stuFilter.varField   		// map the name associated to the filtered field
	var valueOperator = arguments.stuFilter.varOperator 	// map the SQL operator applied to the filter statement (=,<>,LIKE,GTE,LTE etc..)
	var valueFilter = arguments.stuFilter.varFilter 		// map the value assigned to the filtered field

	// Set sqltype depending on valueFilter, which can be either a numeric or a string value:

	var sqltype = (isNumeric(valueFilter) ? "numeric" : "string");

		try {

		// Build an SQL WHERE clause matching the filter

		var FILTER = "#valueField#" & " #valueOperator#" & " :#valueField#";

		// Append the WHERE clause to the query and execute it:

		var sql = "SELECT #args.fieldNames# FROM #args.tableName# 
				   WHERE #FILTER# ORDER BY #args.defaultOrderBy#";

	    var qData = queryExecute( sql, {"#valueField#": {value: valueFilter, cfsqltype: sqltype}}, { datasource: dsn.name } );									   
		
		} catch (database e) {

		// Build the error message and capture it to a variable

		var errorMsg = "#e.sqlState#: #e.message# #e.queryError#";

		// Throw the exception and pass the error message variable for the controller to handle

		throw(type="DBgwFilterError", message="#errorMsg#"); 

		}	

	return qData;

	}	

}