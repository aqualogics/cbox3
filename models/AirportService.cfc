component extends="models.BaseService" accessors="true" singleton {

/**
 * --------------------------------------------------------------------------
 * AirportService constructor
 * --------------------------------------------------------------------------
*/

// The xmlObject was loaded in the parent baseService class after injection of the LoadXMLSchema object.
// The service now instantiates that class with its associated schema XML properties.     

AirportService function init(){

    // Map the schema Xpath statements to the function arguments

		var entityName = "Airport";
		var serviceName = "AirportService";
		var moduleName = "";
        var fieldNamesPath = "/schema/model[1]/entity[4]/propertyName/propertyValue/@name";
		var tableNamePath = "/schema/model[1]/entity[4]/@name";
		var primaryKeyPath = "/schema/model[1]/entity[4]/propertyName[1]/propertyValue/@name";
		var secondaryKeyPath = "";
        var sortIndexPath = "/schema/model[1]/entity[4]/propertyName[2]/propertyValue/@name";

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
 * Instantiate a new Airport object via WireBox
 */

public Airport function new() provider="Airport" {};

// EXISTS

    public boolean function exists(required Airport) {

        // Check whether an airport record has a primary key value

		if (arguments.Airport.isLoaded()) {

			// If the object instance is not empty

			try {

				// Get the primary key stored in the object

				var qry = Super.getByCD(arguments.Airport.getAirportCD());

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

// READ an airport record

    Airport function read( required string airportCD ) {
        
        var qryResult = Super.getByCD(arguments.airportCD);

        // Instantiate an object of type country
        var objAirport = new();

        // Populate this object with the result of the query    
        objAirport.setAirportCD(qryResult["gtw_airport_cd"]);
        objAirport.setAirportName(qryResult["gtw_airport_nm"]);
		objAirport.setAirportCityID(qryResult["gtw_city_id"]);

        // return the object
        return objAirport;
	
	}

// CREATE an airport record

public string function create(required Airport) {

// I insert a new Airport record in the database taking as argument a bean populated with the data to insert.

	var insertKey = "";

	try {

	var params = {
		airportCD: { value: "#Ucase(Trim(arguments.Airport.getAirportCD()))#", cfsqltype: "string" },
		airportName: { value: "#Ucase(Trim(arguments.Airport.getAirportName()))#", cfsqltype: "string" },
		airportCityID: { value: "#Trim(arguments.Airport.getAirportCityID())#", cfsqltype: "numeric" }
	};
	
	var sql = "INSERT INTO tab_airport 
				SET  
				gtw_airport_cd = :airportCD,
				gtw_airport_nm = :airportName,
				gtw_city_id = :airportCityID";

	queryExecute( sql, params, { datasource: dsn.name } );
	
	insertKey = arguments.Airport.getAirportCD();

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
	
// UPDATE an airport record

public boolean function update(required Airport) {

	// I update an airport record in the database taking as argument a bean populated with the data to update

	var boolSuccess = false;	

	try {

	var params = {
		airportCD: { value: "#Ucase(Trim(arguments.Airport.getAirportCD()))#", cfsqltype: "string" },
		airportName: { value: "#Ucase(Trim(arguments.Airport.getAirportName()))#", cfsqltype: "string" },
		airportCityID: { value: "#Trim(arguments.Airport.getAirportCityID())#", cfsqltype: "numeric" }
	};
	
	var sql = "UPDATE tab_airport 
			   SET  gtw_airport_nm = :airportName,
			   		gtw_city_id = :airportCityID
			   WHERE gtw_airport_cd = :airportCD"
				
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
	
// SAVE an airport record

public function save(required Airport) {

	// I save an airport record, either by creating a new entry or updating an existing one.

	var action = '';

	if ( exists(arguments.Airport) ) {

		action = update(arguments.Airport);

	}

	else { 

		action = create(arguments.Airport);

		}

		return action;

	}
	
// DELETE an airport record

public boolean function delete(required string airportCD) {

	return Super.deleteByCD(arguments.airportCD);

	}	
	
////////////////////
// GATEWAY METHODS//	
////////////////////

public query function getAllAirports() {

// I get a list of all airports in the database
	
	return Super.getAllRecords();

	}

public array function airportArrayList(){

// I return a list of all airports as an array of structures (method used in the API handler)	

	return getAllAirports().reduce( ( result, row ) => {
		result.append( row );
		return result;
		}, [] );

	}	

// FILTERED LISTS	

public query function filterByAirportName(required string airportNameFilter, 
									   	  required string airportNameFilterOperator default = "LIKE") {

	// I run a query of all airports in the database matching a required filter

	var stuFilter = structNew();
	stuFilter.varFilter = '%#arguments.airportNameFilter#%';
	stuFilter.varOperator = arguments.airportNameFilterOperator;
	stuFilter.varField = 'gtw_airport_nm';

	return Super.getByFilter(stuFilter);

	}

public query function filterByCityID(required numeric cityIDFilter, 
									 required string cityIDFilterOperator default = "=") {

	// I run a query of all airports in the database matching a required filter

	var stuFilter = structNew();
	stuFilter.varFilter = arguments.cityIDFilter;
	stuFilter.varOperator = arguments.cityIDFilterOperator;
	stuFilter.varField = 'gtw_city_id';

	return Super.getByFilter(stuFilter);

	}	

// Find all records that do NOT match a particular airport code

public query function filterByAirportCode(required string airportCodeFilter, 
										  required string airportCodeFilterOperator default = "<>") {

// I run a query of all countries in the database that do NOT match a required filter

	var stuFilter = structNew();
	stuFilter.varFilter = arguments.airportCodeFilter;
	stuFilter.varOperator = arguments.airportCodeFilterOperator;
	stuFilter.varField = 'gtw_airport_cd';

	return Super.getByFilter(stuFilter);

	}


}	
	