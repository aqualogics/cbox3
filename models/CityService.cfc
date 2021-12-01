component extends="models.BaseService" accessors="true" singleton {

/**
 * --------------------------------------------------------------------------
 * CityService constructor
 * --------------------------------------------------------------------------
*/

// The xmlObject was loaded in the parent baseService class after injection of the LoadXMLSchema object.
// The service now instantiates that class with its associated schema XML properties.     

CityService function init(){

    // Map the schema Xpath statements to the function arguments

		var entityName = "City";
		var serviceName = "CityService";
		var moduleName = "";
        var fieldNamesPath = "/schema/model[1]/entity[2]/propertyName/propertyValue/@name";
		var tableNamePath = "/schema/model[1]/entity[2]/@name";
		var primaryKeyPath = "/schema/model[1]/entity[2]/propertyName[1]/propertyValue/@name";
		var secondaryKeyPath = "";
        var sortIndexPath = "/schema/model[1]/entity[2]/propertyName[2]/propertyValue/@name";

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
 * Instantiate a new City object via WireBox
 */

public City function new() provider="City" {};

// EXISTS

    public boolean function exists(required City) {

        // Check whether a city record has a primary key value

		if (arguments.City.isLoaded()) {

			// If the object instance is not empty

			try {

				// Get the primary key stored in the object

				var qry = Super.getByID(arguments.City.getCityID());

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

// READ a city record

City function read( required cityID ) {
        
	var qryResult = Super.getByID(arguments.cityID);

	// Instantiate an object of type city
	var objCity = new();

	// Populate this object with the result of the query    
	objCity.setCityID(qryResult["cty_city_id"]);
	objCity.setCityName(qryResult["cty_city_nm"]);
	objCity.setCityCD(qryResult["cty_city_cd"]);
	objCity.setCityCountryCD(qryResult["cty_country_cd"]);

	// return the object
	return objCity;

	}

// CREATE a city record

public function create(required City) {

// I insert a new city record in the database taking as argument a city bean with the data to insert.

	var insertKeyID;
	
	try {

	var params = {
		cityName: { value: "#Ucase(Trim(arguments.City.getCityName()))#", cfsqltype: "string" },
		cityCD: { value: "#Ucase(Trim(arguments.City.getCityCD()))#", cfsqltype: "string" },
		cityCountryCD: { value: "#Ucase(Trim(arguments.City.getCityCountryCD()))#", cfsqltype: "string" }
	};
	
	var sql = "INSERT INTO tab_city 
			   SET  
			   cty_city_nm = :cityName,
			   cty_city_cd = :cityCD,
			   cty_country_cd = :cityCountryCD";

	queryExecute( sql, params, { result: "local.result", datasource: dsn.name } );
	
	insertKeyID = result.generatedKey;

	// Should any error arise in the process

	}	catch (database e) {

		// Build the error message and capture it to a variable

		var errorMsg = "#e.sqlState#: #e.message# #e.queryError#";

		// Throw the exception and pass the error message variable for the controller to handle

		throw(type="DBinsertError", message="#errorMsg#"); 

		}

		// Here, we return the generatedKey value, which is an auto-generated row ID value from mySQL

		return insertKeyID;

	}
	
// UPDATE a city record

public boolean function update(required City) {

	// I update a city record taking as argument a city bean populated with the data to update

	var boolSuccess = false;	

	try {

	var params = {
		cityID: { value: "#Trim(arguments.City.getCityID())#", cfsqltype: "numeric" },
		cityName: { value: "#Ucase(Trim(arguments.City.getCityName()))#", cfsqltype: "string" },
		cityCD: { value: "#Ucase(Trim(arguments.City.getCityCD()))#", cfsqltype: "string" },
		cityCountryCD: { value: "#Ucase(Trim(arguments.City.getCityCountryCD()))#", cfsqltype: "string" }
	};
	
	var sql = "UPDATE tab_city 
			   SET  
			   cty_city_nm = :cityName,
			   cty_city_cd = :cityCD,
			   cty_country_cd = :cityCountryCD
			   WHERE cty_city_id = :cityID";

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
	
// SAVE a city record

public function save(required City) {

// I save a city record, either by creating a new entry or updating an existing one.

	var action = '';

	if ( exists(arguments.City) ) {

		action = update(arguments.City);

	}

	else { 

		action = create(arguments.City);

		}

		return action;

	}	

// DELETE a cityzone record

	public boolean function delete(required numeric cityID) {

		return Super.deleteByID(arguments.cityID);

	}
	
///////////////////
// GATEWAY METHODS//	
////////////////////

public query function getAllCities() {

	// I get a list of all cities in the database
	
	return Super.getAllRecords();

	}

public array function cityArrayList(){

	// I return a list of all city records as an array of structures (method used in the API handler)	

		return getAllCities().reduce( ( result, row ) => {
			result.append( row );
			return result;
		}, [] );

	}

// FILTERED LISTS

public query function filterByCityName(required string cityNameFilter, 
									   required string cityNameFilterOperator default = "LIKE") {

	// I run a query of all cities in the database matching a required filter

		var stuFilter = structNew();
		stuFilter.varFilter = '%#arguments.cityNameFilter#%';
		stuFilter.varOperator = arguments.cityNameFilterOperator;
		stuFilter.varField = 'cty_city_nm';

		return Super.getByFilter(stuFilter);

	}

public query function filterByCityCountryCode(required string cityCountryCodeFilter, 
											  required string cityCountryCodeFilterOperator default = "=") {

	// I run a query of all cities in the database matching a required filter

		var stuFilter = structNew();
		stuFilter.varFilter = arguments.cityCountryCodeFilter;
		stuFilter.varOperator = arguments.cityCountryCodeFilterOperator;
		stuFilter.varField = 'cty_country_cd';

		return Super.getByFilter(stuFilter);

	}
	
// Query of all record NOT matching a particular ID

public query function filterByCityID(required numeric cityIDFilter, 
									 required string cityIDFilterOperator default = "<>") {

	// I run a query of all cityzones NOT matching a required filter

		var stuFilter = structNew();
		stuFilter.varFilter = arguments.cityIDFilter;
		stuFilter.varOperator = arguments.cityIDFilterOperator;
		stuFilter.varField = 'cty_city_id';

		return Super.getByFilter(stuFilter);

	}	
	

}	
	