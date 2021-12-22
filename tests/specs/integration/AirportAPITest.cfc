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

		describe( "Airport API test suite", function() {
			
			beforeEach( function( currentSpec ) {
				setup();
				airportSVC = getInstance( "AirportService" );
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

		scenario( "Get a list of airports", function() {
		given( "I make a GET call to /api/airport", function() {
			when( "I have no search filters", function() {
				then( "I will get a list of all airports", function() {
					var event = get( "/api/airport" );
					expect(	event.getStatusCode() ).toBe( 200 );
					var returnedJSON = event.getRenderData().data;
					//debug( returnedJSON );
					expect( returnedJSON ).toHaveKey( "error" );
					expect( returnedJSON.error ).toBeFalse();
					expect( returnedJSON ).toHaveKey( "data" );
					expect( returnedJSON.data ).toBeArray();
					expect( returnedJSON.data ).toHaveLength( 11 );
					});
				});
			});
		});

		scenario( "Get an individual airport for display", function() {
			given( "I make a get call to /api/airport/:airportCD", function() {

				when( "I pass a non existing airportCD", function() {
					then( "I will get a 404 error", function() {
						var airportCD = "ZZZ"
						var event = get( "/api/airport/#airportCD#" );
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

				when( "I pass a valid airportCD", function() {
					then( "I will get a single airport record returned", function() {
						var airportCD = "SIN";
						var event = get( "/api/airport/#airportCD#" );
						expect(	event.getStatusCode() ).toBe( 200 );
						var returnedJSON = event.getRenderData().data;
						//debug( returnedJSON );
						expect( returnedJSON ).toHaveKey( "error" );
						expect( returnedJSON.error ).toBeFalse();
						expect( returnedJSON ).toHaveKey( "data" );
						expect( returnedJSON.data ).toBeStruct();
						expect( returnedJSON.data ).toHaveKey( "airportCD" );
						expect( returnedJSON.data.airportCD ).toBe( "SIN" );
						expect( returnedJSON ).toHaveKey( "messages" );
						expect( returnedJSON.messages ).toBeArray();
						expect( returnedJSON.messages ).toHaveLength( 0 );
					} );
				} );
			} );
		} );

		scenario( "I want to create a new airport", function(){
			given( "I make a call to /api/airport", function() {

				when( "Using a GET method instead of a POST method", function() {
					then( "I will hit the index action instead of the create action", function() {
						var event = get( "/api/airport" );
						expect( event.getCurrentAction() ).toBe(
							"index",
							"Expected to hit index action not [#event.getCurrentAction()#] action"
						);
					 });
				  });
			
				when( "Passing a valid airport record", function() {
					then( "I create a new airport successfully", function(){

					var event = post( "/api/airport", { "airportCD" : "AAA",
														"airportName" : "TEST",
														"airportCityID": 1} );

					expect( event.getCurrentAction() ).toBe(
					"create",
					"Expected to hit create action not [#event.getCurrentAction()#] action"
					);	

					var response = getRequestContext().getPrivateValue( "response" );										
					
					// After creation, the record under test must be found in the database
					//debug(response);

					var objAirport = airportSVC.read( response.getData() );
					expect( airportSVC.exists(objAirport)).toBe(true);
					expect( objAirport.getAirportName()).toBe("TEST");
					expect( objAirport.getAirportCityID()).toBe(1);

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
					expect( returnedJSON.messages[ 1 ] ).toBe( "airport was created successfully!" );
					
					});
				});
			
				when( "Passing invalid airport data", function() {
					then( "I should get an error message", function(){

					// airportCD and airportName values are required but missing

					var event = post( "/api/airport", { "airportCD" : "",
														"airportName" : "",
														"airportCityID": 8 } );

					// Check the returned data 
					var returnedJSON = event.getRenderData().data;
					//debug(returnedJSON);

					expect( returnedJSON.error ).toBeTrue();
					expect( event.getStatusCode() ).toBe( 400 );
					expect( returnedJSON.messages ).toBeArray();
					expect( arraylen(returnedJSON.messages) ).toBeGTE( 1 );

					});
				});
			
				when( "Duplicating an airport record", function() {
					then( "I should get an error message", function(){

					// airportCD primary key is duplicated

					var event = post( "/api/airport", {"airportCD" : "JFK",
													   "airportName" : "TEST",
													   "airportCityID" : 1 } );

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

		scenario( "I want to update an airport", function(){
			given( "I make a call to /api/airport/:airportCD", function(){

				when( "Using a GET method instead of a PUT method", function() {
					then( "I will hit the show action instead of the update action", function() {
						var airportCD = "MEL";
						var event = get( "/api/airport/#airportCD#" );
						expect( event.getCurrentAction() ).toBe(
							"show",
							"I expect to hit show action instead of the update action due to the VERB, but I actually hit [#event.getCurrentAction()#]"
						);
					} );
				} );

				when( "Using a POST method instead of a PUT method", function() {
					then( "I will hit onInvalidHTTPMethod action instead of the update action", function() {
						var airportCD = "SYD";
						var event = post( "/api/airport/#airportCD#" );
						expect( event.getCurrentAction() ).toBe(
							"onInvalidHTTPMethod",
							"I expect to hit onInvalidHTTPMethod action instead of the update action due to the VERB, but I actually hit [#event.getCurrentAction()#]"
						);
					} );
				} );

				when( "Passing a valid airport record", function() {
					then( "I update an airport successfully", function(){

					var airportCD = "FCO";
					var event = put( "/api/airport/#airportCD#", {"airportName" : "TEST23",
																  "airportCityID": 3 } );										

					// Ensure that the record was updated

					var objAirport = airportSVC.read(airportCD);
					expect(objAirport.getAirportName()).tobe("TEST23");
					expect(objAirport.getAirportCityID()).tobe(3);

					// Check the returned data 

					var returnedJSON = event.getRenderData().data;
					//debug(returnedJSON);

					expect( returnedJSON ).toBeStruct();
					expect( returnedJSON.error ).toBeFalse();
					expect( event.getStatusCode() ).toBe( 200 );

					});
				});
			
				when( "Passing invalid airport data", function() {
					then( "I should get an error message", function(){

					// airportName value is required but missing

					var airportCD = "MEL";
					var event = put( "/api/airport/#airportCD#", {"airportName" : "",
																  "airportCityID": 6 } );			
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

		scenario( "I want to delete an airport", function(){
			given( "I make a call to /api/airport/:airportCD", function(){

				when( "Using a GET method instead of a DELETE method", function() {
					then( "I will hit the show action instead of the delete action", function() {
						var airportCD = "BKK";
						var event = get( "/api/airport/#airportCD#" );
						expect( event.getCurrentAction() ).toBe(
							"show",
							"I expect to hit show action instead of the delete action due to the VERB, but I actually hit [#event.getCurrentAction()#]"
						);
					} );
				} );

				when( "Using a POST method instead of a DELETE method", function() {
					then( "I will hit onInvalidHTTPmethod action", function() {
						var airportCD = "EWR";
						var event = post( "/api/airport/#airportCD#" );
						expect( event.getCurrentAction() ).toBe(
							"onInvalidHTTPMethod",
							"I expect to hit onInvalidHTTPMethod action instead of the delete action due to the VERB, but I actually hit [#event.getCurrentAction()#]"
						);
					} );
				} );

				when( "Including a blank in place of the airportCD param", function() {
					then( "I will hit the index action instead of the delete action", function() {
						var airportCD = "";
						var event = get( "/api/airport/#airportCD#" );
						expect( event.getCurrentAction() ).toBe(
							"index",
							"I expect to hit index action instead of the delete action due to the VERB, but I actually hit [#event.getCurrentAction()#]"
						);
					} );
				} );

				when( "Passing a valid airport record with no integrity constraints", function() {
					then( "the airport record will be deleted successfully", function(){

					// First, create a new airport

					var event = post( "/api/airport", { "airportCD" : "AAA",
														"airportName" : "TEST",
														"airportCityID"	: 1	} );

					var returnedJSON = event.getRenderData().data;
					setup();
					var airportCD = returnedJSON.data;

					// Then delete it via an API call

					var event2 = delete( "/api/airport/#airportCD#" );
					var returnedJSON2 = event2.getRenderData().data;

					expect( returnedJSON2.error ).toBeFalse();
					expect( event2.getStatusCode() ).toBe( 200 );
					expect( returnedJSON2.messages[ 1 ] ).toBe( "airport was deleted successfully!" );

					// After deletion, the record under test must be gone
					var objAirport = airportSVC.read( "AAA" );	
					expect( airportSVC.exists(objAirport)).toBe(false);

					});
				});
			
				when( "Passing an invalid airport code", function() {
					then( "API response must return an error message", function(){
					
					var airportCD = "ZZZ";

					// Make sure the airport does not exist

					var objAirport = airportSVC.read( airportCD );
					expect( airportSVC.exists(objAirport)).toBe(false);

					// Attempting to delete this record should fail

					var event = delete( "/api/airport/#airportCD#" );
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
