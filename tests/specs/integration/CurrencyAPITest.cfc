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

		describe( "Currency API test suite", function() {
			
			beforeEach( function( currentSpec ) {
				setup();
				currencySVC = getInstance( "CurrencyService" );
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

		scenario( "Get a list of Currencies", function() {
		given( "I make a GET call to /api/currency", function() {
			when( "I have no search filters", function() {
				then( "I will get a list of all currencies", function() {
					var event = get( "/api/currency" );
					expect(	event.getStatusCode() ).toBe( 200 );
					var returnedJSON = event.getRenderData().data;
					//debug( returnedJSON );
					expect( returnedJSON ).toHaveKey( "error" );
					expect( returnedJSON.error ).toBeFalse();
					expect( returnedJSON ).toHaveKey( "data" );
					expect( returnedJSON.data ).toBeArray();
					expect( returnedJSON.data ).toHaveLength( 6 );
					});
				});
			});
		});

		scenario( "Get an individual currency for display", function() {
			given( "I make a get call to /api/currency/:currencyCD", function() {

				when( "I pass a non existing currencyCD", function() {
					then( "I will get a 404 error", function() {
						var currencyCD = "ZZZ"
						var event = get( "/api/currency/#currencyCD#" );
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

				when( "I pass a valid currencyCD", function() {
					then( "I will get a single currency record returned", function() {
						var currencyCD = "SGD";
						var event = get( "/api/currency/#currencyCD#" );
						expect(	event.getStatusCode() ).toBe( 200 );
						var returnedJSON = event.getRenderData().data;
						//debug( returnedJSON );
						expect( returnedJSON ).toHaveKey( "error" );
						expect( returnedJSON.error ).toBeFalse();
						expect( returnedJSON ).toHaveKey( "data" );
						expect( returnedJSON.data ).toBeStruct();
						expect( returnedJSON.data ).toHaveKey( "currencyCD" );
						expect( returnedJSON.data.currencyCD ).toBe( "SGD" );
						expect( returnedJSON ).toHaveKey( "messages" );
						expect( returnedJSON.messages ).toBeArray();
						expect( returnedJSON.messages ).toHaveLength( 0 );
					} );
				} );
			} );
		} );

		scenario( "I want to create a new currency", function(){
			given( "I make a call to /api/currency", function() {

				when( "Using a get method instead of a post method", function() {
					then( "I will hit the index action instead of the create action", function() {
						var event = get( "/api/currency" );
						expect( event.getCurrentAction() ).toBe(
							"index",
							"Expected to hit index action not [#event.getCurrentAction()#] action"
						);
					 });
				  });
			
				when( "Passing a valid currency record", function() {
					then( "I create a new currency successfully", function(){

					var event = post( "/api/currency", { "currencyCD" : "AAA",
														 "currencyName" : "TEST"} );

					expect( event.getCurrentAction() ).toBe(
					"create",
					"Expected to hit create action not [#event.getCurrentAction()#] action"
					);	

					var response = getRequestContext().getPrivateValue( "response" );										
					
					// After creation, the record under test must be found in the database
					//debug(response);

					var objCurrency = CurrencySVC.read( response.getData() );
					expect( CurrencySVC.exists(objCurrency)).toBe(true);
					expect( objCurrency.getCurrencyName()).toBe("TEST");

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
					expect( returnedJSON.messages[ 1 ] ).toBe( "Currency was created successfully!" );
					
					});
				});
			
				when( "Passing invalid Currency data", function() {
					then( "I should get an error message", function(){

					// CurrencyCD and CurrencyName values are required but missing

					var event = post( "/api/currency", { "CurrencyCD" : "",
														 "CurrencyName" : ""} );

					// Check the returned data 
					var returnedJSON = event.getRenderData().data;
					//debug(returnedJSON);
					expect( returnedJSON.error ).toBeTrue();
					expect( event.getStatusCode() ).toBe( 400 );
					expect( returnedJSON.messages ).toBeArray();
					expect( arraylen(returnedJSON.messages) ).toBeGTE( 1 );

					});
				});
			
				when( "Duplicating a unique Currency index", function() {
					then( "I should get an error message", function(){

					// CurrencyCD primary key is duplicated

					var event = post( "/api/currency", {"CurrencyCD" : "USD",
														"CurrencyName" : "TEST"} );

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

		scenario( "I want to update a currency", function(){
			given( "I make a call to /api/currency/:currencyCD", function(){

				when( "Using a get method instead of a put method", function() {
					then( "I will hit the show action instead of the update action", function() {
						var currencyCD = "USD";
						var event = get( "/api/currency/#currencyCD#" );
						expect( event.getCurrentAction() ).toBe(
							"show",
							"I expect to hit show action instead of the update action due to the VERB, but I actually hit [#event.getCurrentAction()#]"
						);
					} );
				} );

				when( "Using a post method instead of a put method", function() {
					then( "I will hit onInvalidHTTPMethod action instead of the update action", function() {
						var currencyCD = "THB";
						var event = post( "/api/currency/#currencyCD#" );
						expect( event.getCurrentAction() ).toBe(
							"onInvalidHTTPMethod",
							"I expect to hit onInvalidHTTPMethod action instead of the update action due to the VERB, but I actually hit [#event.getCurrentAction()#]"
						);
					} );
				} );

				when( "Passing a valid currency record", function() {
					then( "I update a currency successfully", function(){

					var currencyCD = "EUR";
					var event = put( "/api/currency/#currencyCD#", {"currencyName" : "TEST23"} );										

					// Ensure that the record was updated

					var objCurrency = CurrencySVC.read(CurrencyCD);
					//debug(objCurrency);
					expect(objCurrency.getCurrencyName()).tobe("TEST23");

					// Check the returned data 

					var returnedJSON = event.getRenderData().data;
					expect( returnedJSON ).toBeStruct();
					expect( returnedJSON.error ).toBeFalse();
					expect( event.getStatusCode() ).toBe( 200 );

					});
				});
			
				when( "Passing invalid Currency data", function() {
					then( "I should get an error message", function(){

					// CurrencyName value is required but missing

					var CurrencyCD = "AUD";
					var event = put( "/api/currency/#CurrencyCD#", {"CurrencyName" : ""} );			
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

		scenario( "I want to delete a currency", function(){
			given( "I make a call to /api/currency/:currencyCD", function(){

				when( "Using a get method instead of a delete method", function() {
					then( "I will hit the show action instead of the delete action", function() {
						var currencyCD = "THB";
						var event = get( "/api/currency/#currencyCD#" );
						expect( event.getCurrentAction() ).toBe(
							"show",
							"I expect to hit show action instead of the delete action due to the VERB, but I actually hit [#event.getCurrentAction()#]"
						);
					} );
				} );

				when( "Using a post method instead of a delete method", function() {
					then( "I will hit onInvalidHTTPmethod action", function() {
						var currencyCD = "USD";
						var event = post( "/api/currency/#currencyCD#" );
						expect( event.getCurrentAction() ).toBe(
							"onInvalidHTTPMethod",
							"I expect to hit onInvalidHTTPMethod action instead of the delete action due to the VERB, but I actually hit [#event.getCurrentAction()#]"
						);
					} );
				} );

				when( "Including a space in place of the currencyCD param", function() {
					then( "I will hit the index action instead of the delete action", function() {
						var currencyCD = "";
						var event = get( "/api/currency/#currencyCD#" );
						expect( event.getCurrentAction() ).toBe(
							"index",
							"I expect to hit index action instead of the delete action due to the VERB, but I actually hit [#event.getCurrentAction()#]"
						);
					} );
				} );

				when( "Passing a valid currency record with no integrity constraints", function() {
					then( "the currency record will be deleted successfully", function(){

					// First, create a new currency	

					var event = post( "/api/currency", { "currencyCD" : "AAA",
														 "currencyName" : "TEST"} );

					var returnedJSON = event.getRenderData().data;
					setup();
					var currencyCD = returnedJSON.data;

					// Then delete it via an API call

					var event2 = delete( "/api/currency/#currencyCD#" );
					var returnedJSON2 = event2.getRenderData().data;
					expect( returnedJSON2.error ).toBeFalse();
					expect( event2.getStatusCode() ).toBe( 200 );
					expect( returnedJSON2.messages[ 1 ] ).toBe( "Currency was deleted successfully!" );

					// After deletion, the record under test must be gone
					var objCurrency = CurrencySVC.read( "AAA" );	
					expect( CurrencySVC.exists(objCurrency)).toBe(false);

					});
				});
			
				when( "Passing an invalid Currency code", function() {
					then( "API response must return an error message", function(){
					
					var CurrencyCD = "ZZZ";

					// Make sure the Currency does not exist

					var objCurrency = CurrencySVC.read( "ZZZ" );
					expect( CurrencySVC.exists(objCurrency)).toBe(false);

					// Attempting to delete this record should fail

					var event = delete( "/api/currency/#CurrencyCD#" );
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
