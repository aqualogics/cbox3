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

		describe( "Currency Service test suite", function() {
			
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

						// Empty the databean target instance after each specification run
						var databean = structNew();
						var data2bean = structNew();
					 }
				}
		   } );

		it("can read a currency record", function(){	

				// Mock a new entity bean
				var mockBean = createMock("models.Currency");

        		mockBean.setCurrencyCD("EUR"); 
        		mockBean.setCurrencyName("EURO");
        		
				// Populate a data bean with the data returned by the read method.
				// expect mockBean to match dataBean

				databean = currencySVC.read("EUR");

				// debug(databean.getMemento());
				// debug(databean.isLoaded());

				// Verify that the currency object exists
				
				var isFound = currencySVC.exists(databean);
				expect ( isFound ).toBe( true );
				//debug(isFound);

				expect( databean.getCurrencyCD() ).toBe( mockBean.getCurrencyCD() );
				expect( databean.getCurrencyName() ).toBe( mockBean.getCurrencyName() );
				
			});	

		it("can create a currency record", function(){	
						
				// Mock a new entity bean
				var mockBean = createMock("models.Currency");
        		
        		mockBean.setCurrencyCD("AAA"); 
        		mockBean.setCurrencyName("TEST");
				
				// Simulate FORM data inserts
				
				var insertFormData = structNew();
				
				insertFormData.currencyCD = "AAA";
				insertFormData.currencyName = "TEST";
				
				var dataBean = createObject('component', 'models.Currency').init(
				argumentCollection=insertFormData);
				
				// Populate dataBean with the data returned by the create method.
				// expect mockBean to match dataBean
				
				var sNewCD = currencySVC.create(currency=dataBean);
				dataBean.setCurrencyCD(sNewCD);

				//debug(databean);

				// Verify that the dataBean exists

				var isFound = currencySVC.exists(dataBean);
				expect ( isFound ).toBe( true );
				//debug(isFound);
				
				expect( dataBean.getcurrencyCD() ).toBe( mockBean.getcurrencyCD() );
				expect( dataBean.getcurrencyName() ).toBe( mockBean.getcurrencyName() );
				
			});

		it("cannot duplicate a currency record", function(){	
				
				// Simulate FORM data inserts
				
				var insertFormData = structNew();
				
				insertFormData.currencyCD = "EUR"; // Currency already exists
				insertFormData.currencyName = "TEST";
				
				var dataBean = createObject('component', 'models.Currency').init(
				argumentCollection=insertFormData);
				
				// This test must fail.
				
				try {
					
				var sNewCD = currencySVC.create(currency=dataBean);
				dataBean.setCurrencyCD(sNewCD);
				
				} catch(DBinsertError e) {
					
				// This test must return a database error: SqlState = 23000 , ErrorCode = 1062
				// Duplicate entry for composite key 'UNIQUE'. 

				expect( e.Message ).toInclude ( "23000:", "UNIQUE" );	
					
				} 
				
			});

		it("can update a currency record", function(){	
						
				// Mock a new entity bean
				var mockBean = createMock("models.Currency");
        		
        		mockBean.setCurrencyCD("SGD"); 
        		mockBean.setCurrencyName("TEST SGD"); 
				
				// Load a databean with actual data (before update)
				
				var dataBean = currencySVC.read("SGD");

				// Verify that the dataBean exists

				var currencyExists = currencySVC.exists(dataBean);
				expect ( currencyExists ).toBe( true );
				
				//Simulate FORM data update
				
				var editFormData = structNew();
				
				editFormData.currencyCD = "SGD";
				editFormData.currencyName = "TEST SGD";
				
				//Set the updated FORM values into the databean object.
				
				dataBean.setCurrencyName(editFormData.currencyName);
				// debug(databean.getMemento());
				// debug(databean.isLoaded());
				
				//Pass this bean to the update method
				
				currencySVC.update(Currency=dataBean);
				
				// This test must pass.
				// Populate dataBean with the data returned by the create method.
				// expect mockBean to match dataBean
				
				expect( dataBean.getCurrencyCD() ).toBe( mockBean.getCurrencyCD() );
				expect( dataBean.getCurrencyName() ).toBe( mockBean.getCurrencyName() );
				
				});

		it("can save [UPSERT] a currency record", function(){	
				
				// This test creates a new currency in the table or updates an existing one.		
				// Load an instance of mockBean with the expected data to match

				// Mock a new entity bean
				var mockBean = createMock("models.Currency");		 
				
				// Test an INSERT with a new currency.
				
				mockBean.setCurrencyCD("AAA"); 
        		mockBean.setCurrencyName("TEST");
				
				// Simulate FORM data inserts
				
				var insertFormData = structNew();
				
				insertFormData.currencyCD = "AAA";
				insertFormData.currencyName = "TEST";
				
				var dataBean = createObject('component', 'models.Currency').init(
				argumentCollection=insertFormData);

				// Test that the databean does not have an existing currencyCD, for the SAVE function
				// to call the appropriate method in the service (CREATE instead of UPDATE).

				var currencyExists = currencySVC.exists(dataBean);
				expect ( currencyExists ).toBe( false );
				
				// This test must pass.
				// expect a new currency record to be inserted that matches the above test records
				
				var sNewCD = currencySVC.save(currency=dataBean);
				dataBean.setCurrencyCD(sNewCD);
				
				expect( dataBean.getCurrencyCD() ).toBe( sNewCD );
				expect( dataBean.getCurrencyName() ).toBe( mockBean.getCurrencyName() );
				
				// Test an UPDATE with an existing currency

				// Mock a new entity bean
                var mock2Bean = createMock("models.Currency");	
				
				mock2Bean.setCurrencyCD("SGD"); 
        		mock2Bean.setCurrencyName("TEST SGD");  
				
				// Load another data bean with existing data (before update)
				
				var data2Bean = currencySVC.read("SGD");

				//Simulate FORM data update
				
				var editFormData = structNew();
				
				editFormData.currencyCD = "SGD";
				editFormData.currencyName = "TEST SGD";
				
				//Set the updated FORM values into the data2bean object.
				
				data2Bean.setCurrencyName(editFormData.currencyName); 

				// Now, make sure that currencyCD exists for data2Bean

				var currencyExists = currencySVC.exists(data2Bean);
        		expect ( currencyExists ).toBe( true );
				
				//Pass this bean to the save method
				
				currencySVC.save(currency=data2Bean);	
				
				expect( data2Bean.getCurrencyCD() ).toBe( mock2Bean.getCurrencyCD() );
				expect( data2Bean.getCurrencyName() ).toBe( mock2Bean.getCurrencyName() );
			
				});

		it("can delete a currency with no referential integrity constraint", function(){	

				// Mock a new entity bean

				var mockBean = createMock("models.Currency");	
				
				// Create a new currency record for the purpose of that test.
				// This new currency is not constrained and can therefore be deleted.
        		
        		mockBean.setCurrencyCD("AAA"); 
        		mockBean.setCurrencyName("TEST"); 
				
				// Simulate FORM data inserts
				
				var insertFormData = structNew();
				
				insertFormData.currencyCD = "AAA";
				insertFormData.currencyName = "TEST";
				
				var dataBean = createObject('component', 'models.Currency').init(
				argumentCollection=insertFormData);
				
				// Populate the bean with the new record above. 
				
				var sNewCD = currencySVC.create(currency=dataBean);
				dataBean.setcurrencyCD(sNewCD);
				
				// Verify that the record exists before delete
				
				var ExistBeforeDelete = currencySVC.exists(currency=dataBean);
				expect ( ExistBeforeDelete ).toBe ( true );

				// Expect the newly created record to match mockBean

				expect( dataBean.getCurrencyCD() ).toBe( mockBean.getCurrencyCD() );
				expect( dataBean.getCurrencyName() ).toBe( mockBean.getCurrencyName() );

				// Delete this record
				
				currencySVC.delete(sNewCD); 
				
				// Verify that this record is no longer there
				
				var ExistAfterDelete = currencySVC.exists(currency=dataBean);
				expect ( ExistAfterDelete ).toBe ( false );
				expect( dataBean ).ToBeEmpty;
								
				});

		it("cannot delete a currency referencing a child record", function(){	
				
				// This test must return a database error: SqlState = 23000 , ErrorCode = 1451
				// Cannot delete or update a parent row: a foreign key constraint fails. 
				// referenced tables are:
				// 1 - tab_country  
				
				try {
				
				currencySVC.delete("EUR");
				
				} catch(DBdeleteError e) {
					
				expect( e.Message ).toInclude ( "23000:", "FOREIGN KEY CONSTRAINT" );	
				
				}
				
				}); 

		it("can get all currency records", function(){
					
				// Create a new instance of MockQuery for the purpose of this test		
				var mockQuery = currencySVC.getAllCurrencies();
				
				// Empty the query result set	
				var qCurrencies="";
				
				// Query all currency records found in the table
				qCurrencies = currencySVC.getAllCurrencies();
				//debug(qCurrencies);
				
				// This test must pass.
				// expect the query result to return a matching record count.
				// and at least the approximate number of records.
				
				// Get all records
				
				expect( mockQuery.recordcount ).toBe ( qCurrencies.recordcount );
				expect( mockQuery.recordcount ).toBeGTE ( 1 );
				
				});

		it("can get an array of all currency records", function(){
			
				// Create a new instance of MockQuery for the purpose of this test		
				var mockQuery = currencySVC.getAllCurrencies();
				
				// Create an empty array of currencies	
				var aCurrencies = arrayNew(1);
				
				// retrieve an array of structures to list of all currencies in the table
				aCurrencies = currencySVC.currencyArrayList();
				//debug(aCurrencies);
				
				// Confirm that the returned object is an array
				var bool = isArray(aCurrencies);
				expect( bool ).toBe(true);
				
				// Get all records
				
				expect( arraylen(aCurrencies)).toBe ( mockQuery.recordcount );
				expect( arraylen(aCurrencies)).toBeGTE ( 5 );
				
				});		

		it("can filter currency data by currency name", function(){
					
				// Create a new instance of MockQuery for the purpose of this test		
				var mockQuery = currencySVC.filterByCurrencyName("DOLLAR","LIKE");
				
				// Empty the query result set	
				var qCurrencies="";
				
				// Query currency records by currency name
				qCurrencies = currencySVC.filterByCurrencyName("DOLLAR","LIKE");
				//debug(qCurrencies);
				
				// This test must pass.
				// expect the query result to return one or multiple records
				// because of the default "LIKE" SQL operator used in the query
				
				expect( mockQuery.recordcount ).toBe ( qCurrencies.recordcount );
				expect( mockQuery.recordcount ).toBeGTE ( 1 );
				
				});

		it("can filter currency data by currency code", function(){
				
				// Create a new instance of MockQuery for the purpose of this test		
				var mockQuery = currencySVC.filterByCurrencyCode("EUR","<>");
				
				// Empty the query result set	
				var qCurrencies="";
				
				// Query currency records by code excluding the filtered code
				qCurrencies = currencySVC.filterByCurrencyCode("EUR","<>");
				//debug(qCurrencies);

				// This test must pass.
				// expect the query result to return one or multiple records
				
				expect( mockQuery.recordcount ).toBe ( qCurrencies.recordcount );
				expect( mockQuery.recordcount ).toBeGTE ( 2 );
				
				});	


		});

	}

}
