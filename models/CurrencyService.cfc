component extends="models.BaseService" accessors="true" singleton {

/**
 * --------------------------------------------------------------------------
 * CurrencyService constructor
 * --------------------------------------------------------------------------
*/

// The xmlObject was loaded in the parent baseService class after injection of the LoadXMLSchema object.
// The service now instantiates that class with its associated schema XML properties.     

CurrencyService function init(){

    // Map the schema Xpath statements to the function arguments

		var entityName = "Currency";
		var serviceName = "CurrencyService";
		var moduleName = "";
        var fieldNamesPath = "/schema/model[1]/entity[1]/propertyName/propertyValue/@name";
		var tableNamePath = "/schema/model[1]/entity[1]/@name";
		var primaryKeyPath = "/schema/model[1]/entity[1]/propertyName[1]/propertyValue/@name";
		var secondaryKeyPath = "";
        var sortIndexPath = "/schema/model[1]/entity[1]/propertyName[2]/propertyValue/@name";

    // Build a structure containing the schema to be passed from the parent component

        var Arguments = StructNew();
		Arguments.entityName = "#entityName#";
        Arguments.serviceName = "#serviceName#";
        Arguments.moduleName = "#moduleName#";
        Arguments.fieldNamesPath = "#fieldNamesPath#";
        Arguments.tableNamePath = "#tableNamePath#";
        Arguments.primaryKeyPath = "#primaryKeyPath#";
        Arguments.secondaryKeyPath = "#secondaryKeyPath#";
        Arguments.sortIndexPath = "#sortIndexPath#";
        Super.Init(argumentCollection=Arguments);

    return this;

}

/**
 * Instantiate a new Currency object via WireBox
 */

public Currency function new() provider="Currency" {};

// EXISTS

    public boolean function exists(required Currency) {

        // Check whether a currency record has a primary key value

		if (arguments.Currency.isLoaded()) {

			// If the object instance is not empty

			try {

				// Get the primary key stored in the object

				var qry = Super.getByCD(arguments.Currency.getCurrencyCD());

					} catch (e) {

						var errorMsg = "Object loading failed";
						throw(type="EntityError", message="#errorMsg#"); 	
					}
					
				return booleanFormat(qry.recordcount)

			} else {

				return false;
			}

	}

///////////////////
// CRUD METHODS //
//////////////////

// READ a currency record

    Currency function read( required string currencyCD ) {
        
        var qryResult = Super.getByCD(arguments.currencyCD);

        // Instantiate an object of type currency
        var objCurrency = new();

        // Populate this object with the result of the query    
        objCurrency.setCurrencyCD(qryResult["cur_currency_cd"]);
        objCurrency.setCurrencyName(qryResult["cur_currency_nm"]);

        // return the object
        return objCurrency;
	
	}

// CREATE a currency record

public string function create(required Currency) {

// I insert a new Currency record in the database taking as argument a currency bean populated with the data to insert.

	var insertKey = "";

	try {

	var params = {
		currencyCD: { value: "#Ucase(Trim(arguments.Currency.getCurrencyCD()))#", cfsqltype: "string" },
		currencyName: { value: "#Ucase(Trim(arguments.Currency.getCurrencyName()))#", cfsqltype: "string" }
	};
	
	var sql = "INSERT INTO tab_currency 
				SET  
				cur_currency_cd = :currencyCD,
				cur_currency_nm = :currencyName";

	queryExecute( sql, params, { datasource: dsn.name } );
	
	insertKey = arguments.Currency.getCurrencyCD();

	// Should any error arise in the process

	}	catch (database e) {
		
		// Build the error message and capture it to a variable
		
		var errorMsg = "#e.sqlState#: #e.message# #e.queryError#";

		// Throw the exception and pass the error message variable for the controller to handle

		throw(type="DBinsertError", message="#errorMsg#"); 
  
		}

	// Here we return as a String the record key value from the bean

	return insertKey;

	}
	
// UPDATE a currency record

public boolean function update(required Currency) {

	// I update a currency record in the database taking as argument a currency bean populated with the data to update

	var boolSuccess = false;	

	try {

	var params = {
		currencyCD: { value: "#Ucase(Trim(arguments.Currency.getCurrencyCD()))#", cfsqltype: "string" },
		currencyName: { value: "#Ucase(Trim(arguments.Currency.getCurrencyName()))#", cfsqltype: "string" }
	};
	
	var sql = "UPDATE tab_currency 
			   SET  cur_currency_nm = :currencyName
			   WHERE cur_currency_cd = :currencyCD"
				
	queryExecute( sql, params, { datasource: dsn.name } );	

	boolSuccess = true;

	// Should any error arise in the process

	}	catch(database e) {

		// Build the error message and capture it to a variable

		var errorMsg = "#e.sqlState#: #e.message# #e.queryError#";

		// Throw the exception and pass the error message variable for the controller to handle

		throw(type="DBupdateError", message="#errorMsg#"); 	

		}

	return boolSuccess;	

	}
	
// SAVE a currency record

public function save(required Currency) {

	// I save a currency record, either by creating a new entry or updating an existing one.

	var action = '';

	if ( exists(arguments.Currency) ) {

		action = update(arguments.Currency);

	}

	else { 

		action = create(arguments.Currency);

		}

		return action;

	}
	
// DELETE a currency record

public boolean function delete(required string currencyCD) {

	return Super.deleteByCD(arguments.currencyCD);

	}	
	
////////////////////
// GATEWAY METHODS//	
////////////////////

public query function getAllCurrencies() {

// I get a list of all currencies in the database
	
	return Super.getAllRecords();

	}

public array function currencyArrayList(){

// I return a list of all currency records as an array of structures (method used in the API handler)	

	return getAllCurrencies().reduce( ( result, row ) => {
		result.append( row );
		return result;
		}, [] );

	}	

// FILTERED LISTS	

public query function filterByCurrencyName(required string currencyNameFilter, 
									   	   required string currencyNameFilterOperator default = "LIKE") {

	// I run a query of all currencies in the database matching a required filter

	var stuFilter = structNew();
	stuFilter.varFilter = '%#arguments.currencyNameFilter#%';
	stuFilter.varOperator = arguments.currencyNameFilterOperator;
	stuFilter.varField = 'cur_currency_nm';

	return Super.getByFilter(stuFilter);

	}

// Find all records that do NOT match a particular currency code

public query function filterByCurrencyCode(required string currencyCodeFilter, 
										   required string currencyCodeFilterOperator default = "<>") {

// I run a query of all currencies in the database that do NOT match a required filter

	var stuFilter = structNew();
	stuFilter.varFilter = arguments.currencyCodeFilter;
	stuFilter.varOperator = arguments.currencyCodeFilterOperator;
	stuFilter.varField = 'cur_currency_cd';

	return Super.getByFilter(stuFilter);

	}


}	
	