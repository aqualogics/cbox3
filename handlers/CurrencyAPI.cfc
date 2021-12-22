/**
 * Currency RESTful event handler
 */

component extends="coldbox.system.RestHandler" {

	// Injection
	property name="currencySVC" inject="CurrencyService";

	// HTTP Method Security

	this.allowedMethods = {
		index  		= "GET",  
		create   	= "POST", 
		show 		= "GET", 
		update 		= "PUT,POST,PATCH",
		delete 		= "DELETE"
	};

	/**
	 * Returns a list of currencies
	 * @x-route (GET) /api/currency
	 * @response-200 ~currency/index/responses.json##200
	 */

	function index( event, rc, prc ) cache=true cacheTimeout=60 {
		prc.response.setData(
			currencySVC.currencyArrayList()
		);
	}

	/**
	 * Display (show) a single currency
	 * @x-route (GET) /api/currency/:currencyCD
	 * @x-parameters ~currency/show/parameters.json##parameters
	 * @response-200 ~currency/show/responses.json##200
	 * @response-404 resources/apidocs/_responses/currency.404.json
	 */

	function show( event, rc, prc ) cache=true cacheTimeout=60 {

		var objCurrency = CurrencySVC.read(rc.currencyCD);

		if (CurrencySVC.exists(objCurrency)) {

			prc.response.setData(objCurrency.getMemento());

		} else {

			prc.response.setStatusCode(404)
				.setError(true)
				.addMessage("The requested currency does not exist");
		}
	} 

	/**
	 * Creates a new Currency
	 * @x-route (POST) /api/currency
	 * @requestBody  ~currency/create/requestBody.json
	 * @response-200 ~currency/create/responses.json##200
	 * @response-400 ~currency/create/responses.json##400
	 * @response-500 ~currency/create/responses.json##500
	 */

	function create( event, rc, prc ){

		// Populate an entity object
		
		var objCurrency = populateModel( model="Currency" );
	
		// Validate data based on the bean's instantiated validation constraints
	
		var vResults = validateModel(target=objCurrency);
	
		if(vResults.hasErrors()) {
	
			prc.response.setStatusCode(400)
					.setError(true)
					.setStatusText("Invalid input")
					.addMessage( vResults.getAllErrors());
	
			return;		
	
			} 
	
			// Create the record, return the API response data
	
			try { 
	
				var CurrencyKey = CurrencySVC.create( objCurrency );
	
				} catch(DBinsertError e) { 
	
				// Forward the error message to the API response
			
				prc.response.setStatusCode(500)
				.setError(true)
				.setStatusText("Database insert error")
				.addMessage("Unique index or referential integrity constraint violation");
	
				return;
	
				}
	
			// Otherwise, return a success message with the API response
	
			prc.response.setData(CurrencyKey);
			prc.response.setStatusCode(202)
				.addMessage("Currency was created successfully!");	
	
		}

	/**
	 * Update a Currency
	 * @x-route (PUT) /api/currency/:currencyCD
	 * @requestBody ~currency/update/requestBody.json
	 * @response-200 ~currency/update/responses.json##200
	 * @response-400 ~currency/update/responses.json##400
	 * @response-404 resources/apidocs/_responses/currency.404.json
	 */

	function update( event, rc, prc ){

		// get an entity object
		
		var objCurrency = populateModel( model="Currency", memento=rc );
	
		// Validate data based on the bean's instantiated validation constraints
	
		var vResults = validateModel(target=objCurrency);
		
		if(vResults.hasErrors()) {
	
			prc.response.setStatusCode(400)
					.setError(true)
					.setStatusText("Invalid input")
					.addMessage( vResults.getAllErrors());
	
			return;		
	
			} 
	
		// Ensure that the Currency exists prior to UPDATE
		// If it does not, return an error to the API client
		
			if( !CurrencySVC.exists(objCurrency) ){
	
				prc.response.setStatusCode(404)
				.setError(true)
				.addMessage("Record does not exist");
			
			} else {
	
			// If everything is clean so far, proceed with the update event
	
			try {
	
			// I take a bean as argument and return a boolean	
	
			var boolSuccess = CurrencySVC.update( objCurrency );
	
			// Catch any database error
	
			} catch(DBupdateError e) { 
	
				// Catch the message (errorMsg) thrown as exception in the CurrencyService object 	
	
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
					.addMessage("Currency was updated successfully!");
	
			}				
	
		}
		
	/**
	 * Delete a Currency
	 * @x-route (DELETE) /api/currency/:currencyCD
	 * @x-parameters ~currency/delete/parameters.json##parameters
	 * @response-200 ~currency/delete/responses.json##200
	 * @response-404 resources/apidocs/_responses/currency.404.json
	 */

	function delete( event, rc, prc ){

		// Ensure that the Currency exists prior to DELETE
		var objCurrency = CurrencySVC.read( rc.currencyCD );

		// If it does not, return an error to the API client
		if( !CurrencySVC.exists(objCurrency) ){

			prc.response.setStatusCode(404)
			.setError(true)
			.addMessage("You are attempting to delete a record that does not exist");
		
		} else {

		// If everything is clean so far, proceed with the delete event

		try {

		var success = CurrencySVC.delete(rc.currencyCD);

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
				.addMessage("Currency was deleted successfully!");

			}

	}	


}
