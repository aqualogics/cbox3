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

		describe( "City API test suite", function() {
			
			beforeEach( function( currentSpec ) {
				setup();
				citySVC = getInstance( "CityService" );
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

		scenario( "Get a list of Cities", function() {
		given( "I make a GET call to /api/city", function() {
			when( "I have no search filters", function() {
				then( "I will get a list of all cities", function() {
					var event = get( "/api/city" );
					expect(	event.getStatusCode() ).toBe( 200 );
					var returnedJSON = event.getRenderData().data;
					//debug( returnedJSON );
					expect( returnedJSON ).toHaveKey( "error" );
					expect( returnedJSON.error ).toBeFalse();
					expect( returnedJSON ).toHaveKey( "data" );
					expect( returnedJSON.data ).toBeArray();
					expect( returnedJSON.data ).toHaveLength( 10 );
					});
				});
			});
		});

		scenario( "Get an individual City", function() {
			given( "I make a GET call to /api/city/:cityID", function() {

				when( "I pass a non existing cityID", function() {
					then( "I will get a 404 error", function() {
						var cityID = 999
						var event = get( "/api/city/#cityID#" );
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

				when( "I pass a valid cityID", function() {
					then( "I will get a single City record returned", function() {
						var cityID = 3;
						var event = get( "/api/city/#cityID#" );
						expect(	event.getStatusCode() ).toBe( 200 );
						var returnedJSON = event.getRenderData().data;
						//debug( returnedJSON );
						expect( returnedJSON ).toHaveKey( "error" );
						expect( returnedJSON.error ).toBeFalse();
						expect( returnedJSON ).toHaveKey( "data" );
						expect( returnedJSON.data ).toBeStruct();
						expect( returnedJSON.data ).toHaveKey( "cityID" );
						expect( returnedJSON.data.cityID ).toBe( 3 );
						expect( returnedJSON ).toHaveKey( "messages" );
						expect( returnedJSON.messages ).toBeArray();
						expect( returnedJSON.messages ).toHaveLength( 0 );
					} );
				} );
			} );
		} );

		scenario( "I want to create a new city", function(){
			given( "I make a call to /api/city", function() {

				when( "Using a GET method instead of a POST method", function() {
					then( "I will hit the index action instead of the create action", function() {
						var event = get( "/api/city" );
						expect( event.getCurrentAction() ).toBe(
							"index",
							"Expected to hit index action not [#event.getCurrentAction()#] action"
						);
					 });
				  });
			
				when( "Passing a valid city record", function() {
					then( "I create a new city successfully", function(){

					var event = post( "/api/city", { "cityName" : "TEST",
													 "cityCD" : "",
													 "cityCountryCD" : "IT"} );								 

					var response = getRequestContext().getPrivateValue( "response" );

					// After creation, the record under test must be found in the database

					var objCity = citySVC.read( response.getData() );
					expect( citySVC.exists(objCity)).toBe(true);
					expect( objCity.getCityName()).toBe("TEST");
					//debug(objCity.getMemento());

					// Check the returned data 

					var returnedJSON = event.getRenderData().data;
					expect( returnedJSON ).toBeStruct();
					//debug(returnedJSON);
					expect( returnedJSON ).toHaveKey( "error" );
					expect( returnedJSON.error ).toBeFalse();
					expect( event.getStatusCode() ).toBe( 202 );
					expect( returnedJSON ).toHaveKey( "data" );
					expect( returnedJSON ).toHaveKey( "messages" );
					expect( returnedJSON.messages ).toBeArray();
					expect( returnedJSON.messages ).toHaveLength( 1 );
					expect( returnedJSON.messages[ 1 ] ).toBe( "City was created successfully!" );
					
					});
				});
			
				when( "Passing invalid city data", function() {
					then( "I should get an error message", function(){

					// City name is required and country code must be 2 alpha characters long

					var event = post( "/api/city", { "cityName" : "",
													 "cityCD" : "ABC",
													 "cityCountryCD" : 5 } );

					// Check the returned data 
					var returnedJSON = event.getRenderData().data;
					//debug(returnedJSON);
					expect( returnedJSON.error ).toBeTrue();
					expect( event.getStatusCode() ).toBe( 400 );
					expect( returnedJSON.messages ).toBeArray();
					expect( arraylen(returnedJSON.messages) ).toBeGTE( 1 );

					});
				});
			
				when( "Duplicating a unique city-country index", function() {
					then( "I should get an error message", function(){

					// cityName is duplicated from an existing record

					var event = post( "/api/city/", {"cityName" : "PARIS",
													 "cityCD" : "PAR",
													 "cityCountryCD" : "FR"} );

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

		scenario( "I want to update a city", function(){
			given( "I make a call to /api/city/:cityID", function(){

				when( "Using a GET method instead of a PUT method", function() {
					then( "I will hit the show action instead of the update action", function() {
						var cityID = 3;
						var event = get( "/api/city/#cityID#" );
						expect( event.getCurrentAction() ).toBe(
							"show",
							"I expect to hit show action instead of the update action due to the VERB, but I actually hit [#event.getCurrentAction()#]"
						);
					} );
				} );

				when( "Using a POST method instead of a PUT method", function() {
					then( "I will hit onInvalidHTTPMethod action instead of the update action", function() {
						var cityID = 3;
						var event = post( "/api/city/#cityID#" );
						expect( event.getCurrentAction() ).toBe(
							"onInvalidHTTPMethod",
							"I expect to hit onInvalidHTTPMethod action instead of the update action due to the VERB, but I actually hit [#event.getCurrentAction()#]"
						);
					} );
				} );

				when( "Passing a valid city record", function() {
					then( "I update a city successfully", function(){

					var cityID = 3;
					var event = put( "/api/city/#cityID#", {"cityName" : "ROMA-LAZIO",
															"cityCD" : "LZO",
															"cityCountryCD" : "IT"} );										

					// Ensure that the record was updated

					var objCity = CitySVC.read(cityID);
					//debug(objCity.getMemento());
					expect(objCity.getCityName()).tobe("ROMA-LAZIO");
					expect(objCity.getCityCD()).tobe("LZO");

					// Check the returned data 

					var returnedJSON = event.getRenderData().data;
					expect( returnedJSON ).toBeStruct();
					expect( returnedJSON.error ).toBeFalse();
					expect( event.getStatusCode() ).toBe( 200 );

					});
				});
			
				when( "Passing invalid city data", function() {
					then( "I should get an error message", function(){

					// City name cannot be blank

					var cityID = 6;
					var event = put( "/api/city/#cityID#", {"cityName" : "",
															"cityCD" :"MEL",
															"cityCountryCD" : "AU"} );			
					// Check the returned data 
					var returnedJSON = event.getRenderData().data;
					//debug(returnedJSON);
					expect( returnedJSON.error ).toBeTrue();

					// Expect validation to fail
					expect( event.getStatusCode() ).toBe( 400 );
					expect( returnedJSON.messages ).toBeArray();
					expect( arraylen(returnedJSON.messages) ).toBeGTE( 1 );

					});
				});
			
				when( "Updating a city with an invalid country code", function() {
					then( "I should get an error message", function(){

					// The country is a 2 alpha characters string

					var cityID = 5;
					var event = put( "/api/city/#cityID#", {"cityName" : "BARCELONA",
															"cityCD" : "BCA",
															"cityCountryCD" : 8} );			
					// Check the returned data 
					var returnedJSON = event.getRenderData().data;
					//debug(returnedJSON);
					expect( returnedJSON.error ).toBeTrue();

					// Expect a foreign key constraint violation
					expect( event.getStatusCode() ).toBe( 500 );
					expect( returnedJSON.messages ).toBeArray();
					expect( arraylen(returnedJSON.messages) ).toBeGTE( 1 );

					});
				});
			});
		});

		scenario( "I want to delete a city", function(){
			given( "I make a call to /api/city/:cityID", function(){

				when( "Using a GET method instead of a DELETE method", function() {
					then( "I will hit the show action instead of the delete action", function() {
						var cityID = 6;
						var event = get( "/api/city/#cityID#" );
						expect( event.getCurrentAction() ).toBe(
							"show",
							"I expect to hit show action instead of the delete action due to the VERB, but I actually hit [#event.getCurrentAction()#]"
						);
					} );
				} );

				when( "Using a POST method instead of a DELETE method", function() {
					then( "I will hit onInvalidHTTPmethod action", function() {
						var cityID = 6;
						var event = post( "/api/city/#cityID#" );
						expect( event.getCurrentAction() ).toBe(
							"onInvalidHTTPMethod",
							"I expect to hit onInvalidHTTPMethod action instead of the delete action due to the VERB, but I actually hit [#event.getCurrentAction()#]"
						);
					} );
				} );

				when( "Including a blank value for cityID param", function() {
					then( "I will hit the index action instead of the delete action", function() {
						var cityID = "";
						var event = get( "/api/city/#cityID#" );
						expect( event.getCurrentAction() ).toBe(
							"index",
							"I expect to hit index action instead of the delete action due to the VERB, but I actually hit [#event.getCurrentAction()#]"
						);
					} );
				} );

				when( "Passing a valid city record with no integrity constraints", function() {
					then( "the city record will be deleted successfully", function(){

					// First, create a new city	

					var event = post( "/api/city", { "cityName" : "TEST",
													 "cityCD" : "abc",
													 "cityCountryCD" : "ES"} );

					var returnedJSON = event.getRenderData().data;
					setup();
					var cityID = returnedJSON.data;
					//debug(returnedJSON);

					// Then delete it via an API call

					var event2 = delete( "/api/city/#cityID#" );
					var returnedJSON2 = event2.getRenderData().data;
					expect( returnedJSON2.error ).toBeFalse();
					expect( event2.getStatusCode() ).toBe( 200 );
					expect( returnedJSON2.messages[ 1 ] ).toBe( "City was deleted successfully!" );

					//debug(returnedJSON2);

					// After deletion, the record under test must be gone
					var objCity = CitySVC.read(cityID);	
					expect( CitySVC.exists(objCity)).toBe(false);

					});
				});

				when( "Passing an invalid cityID", function() {
					then( "API response must return an error message", function(){
					
					var cityID = 999;

					// Make sure the City does not exist

					var objCity = CitySVC.read(CityID);
					expect( CitySVC.exists(objCity)).toBe(false);

					// Attempting to delete this record should fail

					var event = delete( "/api/city/#CityID#" );
					var returnedJSON = event.getRenderData().data;
					expect( returnedJSON.error ).toBeTrue();
					expect( event.getStatusCode() ).toBe( 404 );
					expect( returnedJSON.messages[ 1 ] ).toBe( "You are attempting to delete a record that does not exist" );
					//debug(returnedJSON);

					});
				});
			
				when( "Passing a cityID with a referential integrity constraint", function() {
					then( "API response must return an error message", function(){
					
					var cityID = 9; // Singapore has an airport

					// Therefore, attempting to delete this city should fail because of the
					// foreign key constraint relating tab_city to tab_airport

					var event = delete( "/api/city/#CityID#" );
					var returnedJSON = event.getRenderData().data;
	
					expect( returnedJSON.error ).toBeTrue();
					expect( event.getStatusCode() ).toBe( 500 );
					expect( returnedJSON.messages[ 1 ] ).toInclude( "23000" );
					//debug(returnedJSON);

					});
				});
			});			
		});


		});

	}

}
