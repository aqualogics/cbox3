component extends="models.BaseService" accessors="true" singleton {

/**
 * --------------------------------------------------------------------------
 * CountryService constructor
 * --------------------------------------------------------------------------
*/

// The xmlObject was loaded in the parent baseService class after injection of the LoadXMLSchema object.
// The service now instantiates that class with its associated schema XML properties.     

CountryService function init(){

    // Map the schema Xpath statements to the function arguments

		var entityName = "Country";
		var serviceName = "CountryService";
		var moduleName = "";
        var fieldNamesPath = "/schema/model[1]/entity[3]/propertyName/propertyValue/@name";
		var tableNamePath = "/schema/model[1]/entity[3]/@name";
		var primaryKeyPath = "/schema/model[1]/entity[3]/propertyName[1]/propertyValue/@name";
		var secondaryKeyPath = "";
        var sortIndexPath = "/schema/model[1]/entity[3]/propertyName[2]/propertyValue/@name";

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
 * Instantiate a new Country object via WireBox
 */

public Country function new() provider="Country" {};

// EXISTS

    public boolean function exists(required Country) {

        // Check whether a country record has a primary key value

		if (arguments.Country.isLoaded()) {

			// If the object instance is not empty

			try {

				// Get the primary key stored in the object

				var qry = Super.getByCD(arguments.Country.getCountryCD());

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

// READ a country record

    Country function read( required string countryCD ) {
        
        var qryResult = Super.getByCD(arguments.countryCD);

        // Instantiate an object of type country
        var objCountry = new();

        // Populate this object with the result of the query    
        objCountry.setCountryCD(qryResult["cnt_country_cd"]);
        objCountry.setCountryName(qryResult["cnt_country_nm"]);
		objCountry.setCountryCurrencyCD(qryResult["cnt_currency_cd"]);

        // return the object
        return objCountry;
	
	}

// CREATE a country record

public string function create(required Country) {

// I insert a new Currency record in the database taking as argument a currency bean populated with the data to insert.

	var insertKey = "";

	try {

	var params = {
		countryCD: { value: "#Ucase(Trim(arguments.Country.getCountryCD()))#", cfsqltype: "string" },
		countryName: { value: "#Ucase(Trim(arguments.Country.getCountryName()))#", cfsqltype: "string" },
		countryCurrencyCD: { value: "#Ucase(Trim(arguments.Country.getCountryCurrencyCD()))#", cfsqltype: "string" }
	};
	
	var sql = "INSERT INTO tab_country 
				SET  
				cnt_country_cd = :countryCD,
				cnt_country_nm = :countryName,
				cnt_currency_cd = :countryCurrencyCD";

	queryExecute( sql, params, { datasource: dsn.name } );
	
	insertKey = arguments.Country.getCountryCD();

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
	
// UPDATE a country record

public boolean function update(required Country) {

	// I update a country record in the database taking as argument a country bean populated with the data to update

	var boolSuccess = false;	

	try {

	var params = {
		countryCD: { value: "#Ucase(Trim(arguments.Country.getCountryCD()))#", cfsqltype: "string" },
		countryName: { value: "#Ucase(Trim(arguments.Country.getCountryName()))#", cfsqltype: "string" },
		countryCurrencyCD: { value: "#Ucase(Trim(arguments.Country.getCountryCurrencyCD()))#", cfsqltype: "string" }
	};
	
	var sql = "UPDATE tab_country 
			   SET  cnt_country_nm = :countryName,
			   		cnt_currency_cd = :countryCurrencyCD
			   WHERE cnt_country_cd = :countryCD"
				
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
	
// SAVE a country record

public function save(required Country) {

	// I save a country record, either by creating a new entry or updating an existing one.

	var action = '';

	if ( exists(arguments.Country) ) {

		action = update(arguments.Country);

	}

	else { 

		action = create(arguments.Country);

		}

		return action;

	}
	
// DELETE a country record

public boolean function delete(required string countryCD) {

	return Super.deleteByCD(arguments.countryCD);

	}	
	
////////////////////
// GATEWAY METHODS//	
////////////////////

public query function getAllCountries() {

// I get a list of all countries in the database
	
	return Super.getAllRecords();

	}

public array function countryArrayList(){

// I return a list of all country records as an array of structures (method used in the API handler)	

	return getAllCountries().reduce( ( result, row ) => {
		result.append( row );
		return result;
		}, [] );

	}	

// FILTERED LISTS	

public query function filterByCountryName(required string countryNameFilter, 
									   	  required string countryNameFilterOperator default = "LIKE") {

	// I run a query of all countries in the database matching a required filter

	var stuFilter = structNew();
	stuFilter.varFilter = '%#arguments.countryNameFilter#%';
	stuFilter.varOperator = arguments.countryNameFilterOperator;
	stuFilter.varField = 'cnt_country_nm';

	return Super.getByFilter(stuFilter);

	}

public query function filterByCurrencyCode(required string countryCurrencyCDFilter, 
										   required string countryCurrencyCDFilterOperator default = "=") {

	// I run a query of all countries in the database matching a required filter

	var stuFilter = structNew();
	stuFilter.varFilter = arguments.countryCurrencyCDFilter;
	stuFilter.varOperator = arguments.countryCurrencyCDFilterOperator;
	stuFilter.varField = 'cnt_currency_cd';

	return Super.getByFilter(stuFilter);

	}	

// Find all records that do NOT match a particular country code

public query function filterByCountryCode(required string countryCodeFilter, 
										  required string countryCodeFilterOperator default = "<>") {

// I run a query of all countries in the database that do NOT match a required filter

	var stuFilter = structNew();
	stuFilter.varFilter = arguments.countryCodeFilter;
	stuFilter.varOperator = arguments.countryCodeFilterOperator;
	stuFilter.varField = 'cnt_country_cd';

	return Super.getByFilter(stuFilter);

	}


}	
	