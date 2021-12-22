/**
 * Country RESTful event handler
 */

component extends="coldbox.system.RestHandler" {

	// Injection
	property name="countrySVC" inject="CountryService";

	// HTTP Method Security

	this.allowedMethods = {
		index  		= "GET",  
		create   	= "POST", 
		show 		= "GET", 
		update 		= "PUT,POST,PATCH",
		delete 		= "DELETE"
	};

	/**
	 * Returns a list of countries
	 * @x-route (GET) /api/country
	 * @response-200 ~country/index/responses.json##200
	 */

	function index( event, rc, prc ) cache=true cacheTimeout=60 {
		prc.response.setData(
			countrySVC.countryArrayList()
		);
	}

	/**
	 * Display (show) a single country
	 * @x-route (GET) /api/country/:countryCD
	 * @x-parameters ~country/show/parameters.json##parameters
	 * @response-200 ~country/show/responses.json##200
	 * @response-404 resources/apidocs/_responses/country.404.json
	 */

	function show( event, rc, prc ) cache=true cacheTimeout=60 {

		var objCountry = countrySVC.read(rc.countryCD);

		if (countrySVC.exists(objCountry)) {

			prc.response.setData(objCountry.getMemento());

		} else {

			prc.response.setStatusCode(404)
				.setError(true)
				.addMessage("The requested country does not exist");
		}
	} 

	/**
	 * Creates a new country
	 * @x-route (POST) /api/country
	 * @requestBody  ~country/create/requestBody.json
	 * @response-200 ~country/create/responses.json##200
	 * @response-400 ~country/create/responses.json##400
	 * @response-500 ~country/create/responses.json##500
	 */

	function create( event, rc, prc ){

		// Populate an entity object
		
		var objCountry = populateModel( model="Country" );
	
		// Validate data based on the bean's instantiated validation constraints
	
		var vResults = validateModel(target=objCountry);
	
		if(vResults.hasErrors()) {
	
			prc.response.setStatusCode(400)
					.setError(true)
					.setStatusText("Invalid input")
					.addMessage( vResults.getAllErrors());
	
			return;		
	
			} 
	
			// Create the record, return the API response data
	
			try { 
	
				var countryKey = countrySVC.create( objCountry );
	
				} catch(DBinsertError e) { 
	
				// Forward the error message to the API response
			
				prc.response.setStatusCode(500)
				.setError(true)
				.setStatusText("Database insert error")
				.addMessage("Unique index or referential integrity constraint violation");
	
				return;
	
				}
	
			// Otherwise, return a success message with the API response
	
			prc.response.setData(countryKey);
			prc.response.setStatusCode(202)
				.addMessage("country was created successfully!");	
	
		}

	/**
	 * Update a country
	 * @x-route (PUT) /api/country/:countryCD
	 * @requestBody ~country/update/requestBody.json
	 * @response-200 ~country/update/responses.json##200
	 * @response-400 ~country/update/responses.json##400
	 * @response-404 resources/apidocs/_responses/country.404.json
	 * @response-500 ~country/update/responses.json##500
	 */

	function update( event, rc, prc ){

		// get an entity object
		
		var objCountry = populateModel( model="Country", memento=rc );
	
		// Validate data based on the bean's instantiated validation constraints
	
		var vResults = validateModel(target=objCountry);
		
		if(vResults.hasErrors()) {
	
			prc.response.setStatusCode(400)
					.setError(true)
					.setStatusText("Invalid input")
					.addMessage( vResults.getAllErrors());
	
			return;		
	
			} 
	
		// Ensure that the country exists prior to UPDATE
		// If it does not, return an error to the API client
		
			if( !countrySVC.exists(objCountry) ){
	
				prc.response.setStatusCode(404)
				.setError(true)
				.addMessage("Record does not exist");
			
			} else {
	
			// If everything is clean so far, proceed with the update event
	
			try {
	
			// I take a bean as argument and return a boolean	
	
			var boolSuccess = countrySVC.update( objCountry );
	
			// Catch any database error
	
			} catch(DBupdateError e) { 
	
				// Catch the message (errorMsg) thrown as exception in the CountryService object 	
	
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
					.addMessage("Country was updated successfully!");
	
			}				
	
		}
		
	/**
	 * Delete a country
	 * @x-route (DELETE) /api/country/:countryCD
	 * @x-parameters ~country/delete/parameters.json##parameters
	 * @response-200 ~country/delete/responses.json##200
	 * @response-404 resources/apidocs/_responses/country.404.json
	 * @response-500 ~country/delete/responses.json##500
	 */

	function delete( event, rc, prc ){

		// Ensure that the country exists prior to DELETE
		var objCountry = countrySVC.read( rc.countryCD );

		// If it does not, return an error to the API client
		if( !countrySVC.exists(objcountry) ){

			prc.response.setStatusCode(404)
			.setError(true)
			.addMessage("You are attempting to delete a record that does not exist");
		
		} else {

		// If everything is clean so far, proceed with the delete event

		try {

		var success = countrySVC.delete(rc.countryCD);

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
				.addMessage("country was deleted successfully!");

			}

	}	


}
