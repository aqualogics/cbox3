/**
 * City RESTful event handler
 */

component extends="coldbox.system.RestHandler" {

	// Injection
	property name="citySVC" inject="CityService";

	// HTTP Method Security

	this.allowedMethods = {
		index  		= "GET",  
		create   	= "POST", 
		show 		= "GET", 
		update 		= "PUT,POST,PATCH",
		delete 		= "DELETE"
	};

	/**
	 * Returns a list of cities
	 * @x-route (GET) /api/city
	 * @response-200 ~city/index/responses.json##200
	 */

	function index( event, rc, prc ) cache=true cacheTimeout=60 {
		prc.response.setData(
			citySVC.cityArrayList()
		);
	}

	/**
	 * Display (show) a single City.
	 * @x-route (GET) /api/city/:cityID	
	 * @x-parameters ~city/show/parameters.json##parameters
	 * @response-200 ~city/show/responses.json##200
	 * @response-404 resources/apidocs/_responses/city.404.json
	 */

	function show( event, rc, prc ) cache=true cacheTimeout=60{

		var objCity = citySVC.read(rc.cityID);

		if (citySVC.exists(objCity)) {

			prc.response.setData(objCity.getMemento());

		} else {

			prc.response.setStatusCode(404)
				.setError(true)
				.addMessage("The requested city does not exist");
		}
	}
	
	/**
	 * Creates a new City.
	 * @x-route (POST) /api/city
	 * @requestBody ~city/create/requestBody.json
	 * @response-200 ~city/create/responses.json##200
	 * @response-400 ~city/create/responses.json##400
	 * @response-500 ~city/create/responses.json##500
	 */

	function create( event, rc, prc ){

		// Populate an entity object
		
		var objCity = populateModel( model="City" );
	
		// Validate data based on the bean's instantiated validation constraints
	
		var vResults = validateModel(target=objCity);
	
		if(vResults.hasErrors()) {
	
			prc.response.setStatusCode(400)
					.setError(true)
					.setStatusText("Invalid input")
					.addMessage( vResults.getAllErrors());
	
			return;		
	
			} 
	
			// Create the record, return the API response data
	
			try { 
	
				var ID = CitySVC.create(objCity);
	
				} catch(DBinsertError e) { 
	
				// Forward the error message to the API response
			
				prc.response.setStatusCode(500)
				.setError(true)
				.setStatusText("Database insert error")
				.addMessage("Unique index or referential integrity constraint violation");
	
				return;
	
				}
	
			// Otherwise, return a success message with the API response
	
			prc.response.setData(ID);
			prc.response.setStatusCode(202)
				.addMessage("City was created successfully!");	
	
		}

	/**
	 * Update a City
	 * @x-route (PUT) /api/city/:cityID
	 * @requestBody ~city/update/requestBody.json
	 * @response-200 ~city/update/responses.json##200
	 * @response-400 ~city/update/responses.json##400
	 * @response-404 resources/apidocs/_responses/city.404.json
	 * @response-500 ~city/update/responses.json##500
	 */

	function update( event, rc, prc ){

		// get an entity object populated with data from the Request Collection
		
		var objCity = populateModel( model="City", memento=rc );
	
		// Validate data based on the bean's instantiated validation constraints
	
		var vResults = validateModel(target=objCity);
		
		if(vResults.hasErrors()) {
	
			prc.response.setStatusCode(400)
					.setError(true)
					.setStatusText("Invalid input")
					.addMessage( vResults.getAllErrors());
	
			return;		
	
			} 
	
		// Ensure that the City exists prior to UPDATE
		// If it does not, return an error to the API client
		
			if( !CitySVC.exists(objCity) ){
	
				prc.response.setStatusCode(404)
				.setError(true)
				.addMessage("Record does not exist");
			
			} else {
	
			// If everything is clean so far, proceed with the update event
	
			try {
	
			// I take a bean as argument and return a boolean	
	
			var boolSuccess = CitySVC.update(objCity);
	
			// Catch any database error
	
			} catch(DBupdateError e) { 
	
				// Catch the message (errorMsg) thrown as exception in the CityService object 	
	
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
					.addMessage("City was updated successfully!");
	
			}				
	
		}
		
	/**
	 * Delete a City
	 * @x-route (DELETE) /api/city/:cityID
	 * @x-parameters ~city/delete/parameters.json##parameters
	 * @response-200 ~city/delete/responses.json##200
	 * @response-404 resources/apidocs/_responses/city.404.json
	 * @response-500 ~city/delete/responses.json##500
	 */

	function delete( event, rc, prc ){

		// Ensure that the City exists prior to DELETE
		var objCity = CitySVC.read(rc.CityID);

		// If it does not, return an error to the API client
		if( !CitySVC.exists(objCity) ){

			prc.response.setStatusCode(404)
			.setError(true)
			.addMessage("You are attempting to delete a record that does not exist");
		
		} else {

		// If everything is clean so far, proceed with the delete event

		try {

		var success = CitySVC.delete(rc.CityID);

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
				.addMessage("City was deleted successfully!");

			}

	} 

}
