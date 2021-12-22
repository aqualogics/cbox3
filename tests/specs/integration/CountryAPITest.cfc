component extends="coldbox.system.testing.BaseTestCase" {
	
	/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll() {
		structDelete( application, "cbController" );
		structDelete( application, "wirebox" );
		super.beforeAll();
	}

	function afterAll() {
		super.afterAll();
	}

	/*********************************** BDD SUITES ***********************************/
	
	function run(){

		describe( "Country API test suite", function() {
			
			beforeEach( function( currentSpec ) {
				setup();
				countrySVC = getInstance( "CountryService" );
			} );

			aroundEach( function( spec, suite ){

				transaction action="begin"{

					 try {

						arguments.spec.body();

					 } catch( Any e ) {

						rethrow;

					 } finally {

						transaction action="rollback";

						// Reset response parameters
						var response = "";
						var returnedJSON = {};

					 }
				}
		    });

		scenario( "Get a list of Countries", function() {
		given( "I make a GET call to /api/country", function() {
			when( "I have no search filters", function() {
				then( "I will get a list of all countries", function() {
					var event = get( "/api/country" );
					expect(	event.getStatusCode() ).toBe( 200 );
					var returnedJSON = event.getRenderData().data;
					debug( returnedJSON );
					expect( returnedJSON ).toHaveKey( "error" );
					expect( returnedJSON.error ).toBeFalse();
					expect( returnedJSON ).toHaveKey( "data" );
					expect( returnedJSON.data ).toBeArray();
					expect( returnedJSON.data ).toHaveLength( 9 );
					});
				});
			});
		});

		scenario( "Get an individual country for display", function() {
			given( "I make a get call to /api/country/:countryCD", function() {

				when( "I pass a non existing countryCD", function() {
					then( "I will get a 404 error", function() {
						var countryCD = "ZZ"
						var event = get( "/api/country/#countryCD#" );
						var returnedJSON = event.getRenderData().data;
						//debug( returnedJSON );
						expect( returnedJSON.data ).toBeStruct();
						expect( returnedJSON ).toHaveKey( "error" );
						expect( returnedJSON.error ).toBeTrue();
						expect(	event.getStatusCode() ).toBe( 404 );
						expect( returnedJSON ).toHaveKey( "messages" );
						expect( returnedJSON.messages ).toBeArray();
						expect( returnedJSON.messages ).toHaveLength( 1 );
					} );
				} );

				when( "I pass a valid countryCD", function() {
					then( "I will get a single country record returned", function() {
						var countryCD = "SG";
						var event = get( "/api/country/#countryCD#" );
						expect(	event.getStatusCode() ).toBe( 200 );
						var returnedJSON = event.getRenderData().data;
						//debug( returnedJSON );
						expect( returnedJSON ).toHaveKey( "error" );
						expect( returnedJSON.error ).toBeFalse();
						expect( returnedJSON ).toHaveKey( "data" );
						expect( returnedJSON.data ).toBeStruct();
						expect( returnedJSON.data ).toHaveKey( "countryCD" );
						expect( returnedJSON.data.countryCD ).toBe( "SG" );
						expect( returnedJSON ).toHaveKey( "messages" );
						expect( returnedJSON.messages ).toBeArray();
						expect( returnedJSON.messages ).toHaveLength( 0 );
					} );
				} );
			} );
		} );

		scenario( "I want to create a new country", function(){
			given( "I make a call to /api/country", function() {

				when( "Using a GET method instead of a POST method", function() {
					then( "I will hit the index action instead of the create action", function() {
						var event = get( "/api/country" );
						expect( event.getCurrentAction() ).toBe(
							"index",
							"Expected to hit index action not [#event.getCurrentAction()#] action"
						);
					 });
				  });
			
				when( "Passing a valid country record", function() {
					then( "I create a new country successfully", function(){

					var event = post( "/api/country", { "countryCD" : "AA",
														"countryName" : "TEST",
														"countryCurrencyCD": "EUR"} );

					expect( event.getCurrentAction() ).toBe(
					"create",
					"Expected to hit create action not [#event.getCurrentAction()#] action"
					);	

					var response = getRequestContext().getPrivateValue( "response" );										
					
					// After creation, the record under test must be found in the database
					//debug(response);

					var objCountry = CountrySVC.read( response.getData() );
					expect( CountrySVC.exists(objCountry)).toBe(true);
					expect( objCountry.getCountryName()).toBe("TEST");
					expect( objCountry.getCountryCurrencyCD()).toBe("EUR");

					// Check the returned data 

					var returnedJSON = event.getRenderData().data;
					//debug(returnedJSON);

					expect( returnedJSON ).toBeStruct();
					expect( returnedJSON ).toHaveKey( "error" );
					expect( returnedJSON.error ).toBeFalse();
					expect( event.getStatusCode() ).toBe( 202 );
					expect( returnedJSON ).toHaveKey( "data" );
					expect( returnedJSON ).toHaveKey( "messages" );
					expect( returnedJSON.messages ).toBeArray();
					expect( returnedJSON.messages ).toHaveLength( 1 );
					expect( returnedJSON.messages[ 1 ] ).toBe( "Country was created successfully!" );
					
					});
				});
			
				when( "Passing invalid Country data", function() {
					then( "I should get an error message", function(){

					// CountryCD and CountryName values are required but missing

					var event = post( "/api/country", { "CountryCD" : "",
														"CountryName" : "",
														"CountryCurrencyCD": "USD"} );

					// Check the returned data 
					var returnedJSON = event.getRenderData().data;
					//debug(returnedJSON);
					expect( returnedJSON.error ).toBeTrue();
					expect( event.getStatusCode() ).toBe( 400 );
					expect( returnedJSON.messages ).toBeArray();
					expect( arraylen(returnedJSON.messages) ).toBeGTE( 1 );

					});
				});
			
				when( "Duplicating a Country record", function() {
					then( "I should get an error message", function(){

					// CountryCD primary key is duplicated

					var event = post( "/api/country", {"CountryCD" : "ES",
													   "CountryName" : "TEST",
													   "CountryCurrencyCD" : "EUR"} );

					// Check the returned data 
					var returnedJSON = event.getRenderData().data;
					//debug(returnedJSON);
					expect( returnedJSON.error ).toBeTrue();
					expect( event.getStatusCode() ).toBe( 500 );
					expect( returnedJSON.messages ).toBeArray();
					expect( returnedJSON.messages[1] ).toInclude("Constraint violation");

					});
				});
			});
		});

		scenario( "I want to update a country", function(){
			given( "I make a call to /api/country/:countryCD", function(){

				when( "Using a GET method instead of a PUT method", function() {
					then( "I will hit the show action instead of the update action", function() {
						var countryCD = "US";
						var event = get( "/api/country/#countryCD#" );
						expect( event.getCurrentAction() ).toBe(
							"show",
							"I expect to hit show action instead of the update action due to the VERB, but I actually hit [#event.getCurrentAction()#]"
						);
					} );
				} );

				when( "Using a POST method instead of a PUT method", function() {
					then( "I will hit onInvalidHTTPMethod action instead of the update action", function() {
						var countryCD = "TH";
						var event = post( "/api/country/#countryCD#" );
						expect( event.getCurrentAction() ).toBe(
							"onInvalidHTTPMethod",
							"I expect to hit onInvalidHTTPMethod action instead of the update action due to the VERB, but I actually hit [#event.getCurrentAction()#]"
						);
					} );
				} );

				when( "Passing a valid country record", function() {
					then( "I update a country successfully", function(){

					var countryCD = "DE";
					var event = put( "/api/country/#countryCD#", {"countryName" : "TEST23",
																  "countryCurrencyCD": "EUR"} );										

					// Ensure that the record was updated

					var objCountry = CountrySVC.read(countryCD);
					expect(objCountry.getCountryName()).tobe("TEST23");
					expect(objCountry.getCountryCurrencyCD()).tobe("EUR");

					// Check the returned data 

					var returnedJSON = event.getRenderData().data;
					//debug(returnedJSON);

					expect( returnedJSON ).toBeStruct();
					expect( returnedJSON.error ).toBeFalse();
					expect( event.getStatusCode() ).toBe( 200 );

					});
				});
			
				when( "Passing invalid Country data", function() {
					then( "I should get an error message", function(){

					// CountryName value is required but missing

					var countryCD = "AU";
					var event = put( "/api/country/#countryCD#", {"CountryName" : "",
																  "CountryCurrencyCD": "AUD"} );			
					// Check the returned data 
					var returnedJSON = event.getRenderData().data;
					//debug(returnedJSON);

					expect( returnedJSON.error ).toBeTrue();
					expect( event.getStatusCode() ).toBe( 400 );
					expect( returnedJSON.messages ).toBeArray();
					expect( arraylen(returnedJSON.messages) ).toBeGTE( 1 );

					});
				});
			});
		});

		scenario( "I want to delete a country", function(){
			given( "I make a call to /api/country/:countryCD", function(){

				when( "Using a GET method instead of a DELETE method", function() {
					then( "I will hit the show action instead of the delete action", function() {
						var countryCD = "TH";
						var event = get( "/api/country/#countryCD#" );
						expect( event.getCurrentAction() ).toBe(
							"show",
							"I expect to hit show action instead of the delete action due to the VERB, but I actually hit [#event.getCurrentAction()#]"
						);
					} );
				} );

				when( "Using a POST method instead of a DELETE method", function() {
					then( "I will hit onInvalidHTTPmethod action", function() {
						var countryCD = "US";
						var event = post( "/api/country/#countryCD#" );
						expect( event.getCurrentAction() ).toBe(
							"onInvalidHTTPMethod",
							"I expect to hit onInvalidHTTPMethod action instead of the delete action due to the VERB, but I actually hit [#event.getCurrentAction()#]"
						);
					} );
				} );

				when( "Including a blank in place of the countryCD param", function() {
					then( "I will hit the index action instead of the delete action", function() {
						var countryCD = "";
						var event = get( "/api/country/#countryCD#" );
						expect( event.getCurrentAction() ).toBe(
							"index",
							"I expect to hit index action instead of the delete action due to the VERB, but I actually hit [#event.getCurrentAction()#]"
						);
					} );
				} );

				when( "Passing a valid country record with no integrity constraints", function() {
					then( "the country record will be deleted successfully", function(){

					// First, create a new country

					var event = post( "/api/country", { "countryCD" : "AA",
														"countryName" : "TEST",
														"countryCurrencyCD"	: "EUR"	} );

					var returnedJSON = event.getRenderData().data;
					setup();
					var countryCD = returnedJSON.data;

					// Then delete it via an API call

					var event2 = delete( "/api/country/#countryCD#" );
					var returnedJSON2 = event2.getRenderData().data;

					expect( returnedJSON2.error ).toBeFalse();
					expect( event2.getStatusCode() ).toBe( 200 );
					expect( returnedJSON2.messages[ 1 ] ).toBe( "Country was deleted successfully!" );

					// After deletion, the record under test must be gone
					var objCountry = countrySVC.read( "AA" );	
					expect( countrySVC.exists(objCountry)).toBe(false);

					});
				});
			
				when( "Passing an invalid Country code", function() {
					then( "API response must return an error message", function(){
					
					var countryCD = "ZZ";

					// Make sure the Country does not exist

					var objCountry = CountrySVC.read( countryCD );
					expect( countrySVC.exists(objCountry)).toBe(false);

					// Attempting to delete this record should fail

					var event = delete( "/api/country/#countryCD#" );
					var returnedJSON = event.getRenderData().data;

					expect( returnedJSON.error ).toBeTrue();
					expect( event.getStatusCode() ).toBe( 404 );
					expect( returnedJSON.messages[ 1 ] ).toBe( "You are attempting to delete a record that does not exist" );
					//debug(returnedJSON);

					});
				});
			});	
		});


		});

	}

}
