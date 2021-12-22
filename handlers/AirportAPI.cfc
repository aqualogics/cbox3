/**
 * Airport RESTful event handler
 */

component extends="coldbox.system.RestHandler" {

	// Injection
	property name="airportSVC" inject="AirportService";

	// HTTP Method Security

	this.allowedMethods = {
		index  		= "GET",  
		create   	= "POST", 
		show 		= "GET", 
		update 		= "PUT,POST,PATCH",
		delete 		= "DELETE"
	};

	/**
	 * Returns a list of airports
	 * @x-route (GET) /api/airport
	 * @response-200 ~airport/index/responses.json##200
	 */

	function index( event, rc, prc ) cache=true cacheTimeout=60 {
		prc.response.setData(
			airportSVC.airportArrayList()
		);
	}

	/**
	 * Display (show) a single airport
	 * @x-route (GET) /api/airport/:airportCD
	 * @x-parameters ~airport/show/parameters.json##parameters
	 * @response-200 ~airport/show/responses.json##200
	 * @response-404 resources/apidocs/_responses/airport.404.json
	 */

	function show( event, rc, prc ) cache=true cacheTimeout=60 {

		var objAirport = airportSVC.read(rc.airportCD);

		if (airportSVC.exists(objAirport)) {

			prc.response.setData(objAirport.getMemento());

		} else {

			prc.response.setStatusCode(404)
				.setError(true)
				.addMessage("The requested airport does not exist");
		}
	} 

	/**
	 * Creates a new airport
	 * @x-route (POST) /api/airport
	 * @requestBody  ~airport/create/requestBody.json
	 * @response-200 ~airport/create/responses.json##200
	 * @response-400 ~airport/create/responses.json##400
	 * @response-500 ~airport/create/responses.json##500
	 */

	function create( event, rc, prc ){

		// Populate an entity object
		
		var objAirport = populateModel( model="Airport" );
	
		// Validate data based on the bean's instantiated validation constraints
	
		var vResults = validateModel(target=objAirport);
	
		if(vResults.hasErrors()) {
	
			prc.response.setStatusCode(400)
					.setError(true)
					.setStatusText("Invalid input")
					.addMessage( vResults.getAllErrors());
	
			return;		
	
			} 
	
			// Create the record, return the API response data
	
			try { 
	
				var airportKey = airportSVC.create( objAirport );
	
				} catch(DBinsertError e) { 
	
				// Forward the error message to the API response
			
				prc.response.setStatusCode(500)
				.setError(true)
				.setStatusText("Database insert error")
				.addMessage("Unique index or referential integrity constraint violation");
	
				return;
	
				}
	
			// Otherwise, return a success message with the API response
	
			prc.response.setData(airportKey);
			prc.response.setStatusCode(202)
				.addMessage("Airport was created successfully!");	
	
		}

	/**
	 * Update an airport
	 * @x-route (PUT) /api/airport/:airportCD
	 * @requestBody ~airport/update/requestBody.json
	 * @response-200 ~airport/update/responses.json##200
	 * @response-400 ~airport/update/responses.json##400
	 * @response-404 resources/apidocs/_responses/airport.404.json
	 * @response-500 ~airport/update/responses.json##500
	 */

	function update( event, rc, prc ){

		// get an entity object
		
		var objAirport = populateModel( model="airport", memento=rc );
	
		// Validate data based on the bean's instantiated validation constraints
	
		var vResults = validateModel(target=objAirport);
		
		if(vResults.hasErrors()) {
	
			prc.response.setStatusCode(400)
					.setError(true)
					.setStatusText("Invalid input")
					.addMessage( vResults.getAllErrors());
	
			return;		
	
			} 
	
		// Ensure that the airport exists prior to UPDATE
		// If it does not, return an error to the API client
		
			if( !airportSVC.exists(objAirport) ){
	
				prc.response.setStatusCode(404)
				.setError(true)
				.addMessage("Record does not exist");
			
			} else {
	
			// If everything is clean so far, proceed with the update event
	
			try {
	
			// I take a bean as argument and return a boolean	
	
			var boolSuccess = airportSVC.update( objAirport );
	
			// Catch any database error
	
			} catch(DBupdateError e) { 
	
				// Catch the message (errorMsg) thrown as exception in the airportService object 	
	
				prc.errorMsg = "#e.message#";
	
				// Forward the error message to the API response
	
				prc.response.setStatusCode(500)
				.setError(true)
				.setStatusText("Database update error")
				.addMessage("#prc.errorMsg#");
	
				return;
		
				}
	
			// Otherwise, return a success message with the API response
			
			prc.response.setData(boolSuccess);
			prc.response.setStatusCode(200)
					.addMessage("airport was updated successfully!");
	
			}				
	
		}
		
	/**
	 * Delete a airport
	 * @x-route (DELETE) /api/airport/:airportCD
	 * @x-parameters ~airport/delete/parameters.json##parameters
	 * @response-200 ~airport/delete/responses.json##200
	 * @response-404 resources/apidocs/_responses/airport.404.json
	 */

	function delete( event, rc, prc ){

		// Ensure that the airport exists prior to DELETE
		var objAirport = airportSVC.read( rc.airportCD );

		// If it does not, return an error to the API client
		if( !airportSVC.exists(objAirport) ){

			prc.response.setStatusCode(404)
			.setError(true)
			.addMessage("You are attempting to delete a record that does not exist");
		
		} else {

		// If everything is clean so far, proceed with the delete event

		try {

		var success = airportSVC.delete(rc.airportCD);

		// Catch any database error

			} catch(DBdeleteError e) { 

			// Catch the message (errorMsg) thrown as exception 	

			prc.errorMsg = "#e.message#";

			// Forward the error message to the API response

			prc.response.setStatusCode(500)
			.setError(true)
			.setStatusText("Database integrity constraint error")
			.addMessage("#prc.errorMsg#");

			return;
	
			}

			// Otherwise, return a success message with the API response

				prc.response.setData( success ); 
				prc.response.setStatusCode(200)
				.addMessage("airport was deleted successfully!");

		}

	}	

}
