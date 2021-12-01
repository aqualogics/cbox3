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

		describe( "Country Service test suite", function() {
			
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

						// Empty the databean target instance after each specification run
						var databean = structNew();
						var data2bean = structNew();
					 }
				}
		   } );

		it("can read a country record", function(){	

				// Mock a new entity bean
				var mockBean = createMock("models.Country");

        		mockBean.setCountryCD("TH"); 
        		mockBean.setCountryName("THAILAND");
				mockBean.setCountryCurrencyCD("THB");
        		
				// Populate a data bean with the data returned by the read method.
				// expect mockBean to match dataBean

				databean = countrySVC.read("TH");

				// debug(databean.getMemento());
				// debug(databean.isLoaded());

				// Verify that the country object exists
				
				var isFound = countrySVC.exists(databean);
				expect ( isFound ).toBe( true );
				//debug(isFound);

				expect( databean.getCountryCD() ).toBe( mockBean.getCountryCD() );
				expect( databean.getCountryName() ).toBe( mockBean.getCountryName() );
				expect( databean.getCountryCurrencyCD() ).toBe( mockBean.getCountryCurrencyCD() );
				
			});	

		it("can create a country record", function(){	
						
				// Mock a new entity bean
				var mockBean = createMock("models.Country");
        		
        		mockBean.setCountryCD("AA"); 
        		mockBean.setCountryName("TEST");
				mockBean.setCountryCurrencyCD("EUR");
				
				// Simulate FORM data inserts
				
				var insertFormData = structNew();
				
				insertFormData.countryCD = "AA";
				insertFormData.countryName = "TEST";
				insertFormData.countryCurrencyCD = "EUR";
				
				var dataBean = createObject('component', 'models.Country').init(
				argumentCollection=insertFormData);
				
				// Populate dataBean with the data returned by the create method.
				// expect mockBean to match dataBean
				
				var sNewCD = countrySVC.create(country=dataBean);
				dataBean.setCountryCD(sNewCD);

				//debug(databean);

				// Verify that the dataBean exists

				var isFound = countrySVC.exists(dataBean);
				expect ( isFound ).toBe( true );
				//debug(isFound);
				
				expect( dataBean.getCountryCD() ).toBe( mockBean.getCountryCD() );
				expect( dataBean.getCountryName() ).toBe( mockBean.getCountryName() );
				expect( dataBean.getCountryCurrencyCD() ).toBe( mockBean.getCountryCurrencyCD() );
				
			});

		it("cannot duplicate a country record", function(){	
				
				// Simulate FORM data inserts
				
				var insertFormData = structNew();
				
				insertFormData.countryCD = "SG"; // Countrt already exists
				insertFormData.countryName = "TEST";
				
				var dataBean = createObject('component', 'models.Country').init(
				argumentCollection=insertFormData);
				
				// This test must fail.
				
				try {
					
				var sNewCD = countrySVC.create(country=dataBean);
				dataBean.setCountryCD(sNewCD);
				
				} catch(DBinsertError e) {
					
				// This test must return a database error: SqlState = 23000 , ErrorCode = 1062
				// Duplicate entry for composite key 'UNIQUE'. 

				expect( e.Message ).toInclude ( "23000:", "UNIQUE" );	
					
				} 
				
			});

		it("can update a country record", function(){	
						
				// Mock a new entity bean
				var mockBean = createMock("models.Country");
        		
        		mockBean.setCountryCD("SG"); 
        		mockBean.setCountryName("SINGAPURA");
				mockBean.setCountryCurrencyCD("THB"); 
				
				// Load a databean with actual data (before update)
				
				var dataBean = countrySVC.read("SG");

				// Verify that the dataBean exists

				var countryExists = countrySVC.exists(dataBean);
				expect ( countryExists ).toBe( true );
				
				//Simulate FORM data update
				
				var editFormData = structNew();
				
				editFormData.countryCD = "SG";
				editFormData.countryName = "SINGAPURA";
				editFormData.countryCurrencyCD = "THB";
				
				//Set the updated FORM values into the databean object.
				
				dataBean.setCountryName(editFormData.countryName);
				dataBean.setCountryCurrencyCD(editFormData.countryCurrencyCD);
				// debug(databean.getMemento());
				// debug(databean.isLoaded());
				
				//Pass this bean to the update method
				
				countrySVC.update(Country=dataBean);
				
				// This test must pass.
				// Populate dataBean with the data returned by the create method.
				// expect mockBean to match dataBean
				
				expect( dataBean.getCountryCD() ).toBe( mockBean.getCountryCD() );
				expect( dataBean.getCountryName() ).toBe( mockBean.getCountryName() );
				expect( dataBean.getCountryCurrencyCD() ).toBe( mockBean.getCountryCurrencyCD() );
				
				});

		it("can save [UPSERT] a country record", function(){	
				
				// This test creates a new country in the table or updates an existing one.		
				// Load an instance of mockBean with the expected data to match

				// Mock a new entity bean
				var mockBean = createMock("models.Country");		 
				
				// Test an INSERT with a new country.
				
				mockBean.setCountryCD("AA"); 
        		mockBean.setCountryName("TEST");
				mockBean.setCountryCurrencyCD("EUR");
				
				// Simulate FORM data inserts
				
				var insertFormData = structNew();
				
				insertFormData.countryCD = "AA";
				insertFormData.countryName = "TEST";
				insertFormData.countryCurrencyCD = "EUR";
				
				var dataBean = createObject('component', 'models.Country').init(
				argumentCollection=insertFormData);

				// Test that the databean does not have an existing countryCD, for the SAVE function
				// to call the appropriate method in the service (CREATE instead of UPDATE).

				var countryExists = countrySVC.exists(dataBean);
				expect ( countryExists ).toBe( false );
				
				// This test must pass.
				// expect a new country record to be inserted that matches the above test records
				
				var sNewCD = countrySVC.save(country=dataBean);
				dataBean.setCountryCD(sNewCD);
				
				expect( dataBean.getCountryCD() ).toBe( sNewCD );
				expect( dataBean.getCountryName() ).toBe( mockBean.getCountryName() );
				expect( dataBean.getCountryCurrencyCD() ).toBe( mockBean.getCountryCurrencyCD() );
				
				// Test an UPDATE with an existing country

				// Mock a new entity bean
                var mock2Bean = createMock("models.Country");	
				
				mock2Bean.setCountryCD("SG"); 
        		mock2Bean.setCountryName("SINGAPURA");
				mock2Bean.setCountryCurrencyCD("THB");  
				
				// Load another data bean with existing data (before update)
				
				var data2Bean = countrySVC.read("SG");

				//Simulate FORM data update
				
				var editFormData = structNew();
				
				editFormData.countryCD = "SG";
				editFormData.countryName = "SINGAPURA";
				editFormData.countryCurrencyCD = "THB";
				
				//Set the updated FORM values into the data2bean object.
				
				data2Bean.setCountryName(editFormData.countryName);
				data2Bean.setCountryCurrencyCD(editFormData.countryCurrencyCD);  

				// Now, make sure that countryCD exists for data2Bean

				var countryExists = countrySVC.exists(data2Bean);
        		expect ( countryExists ).toBe( true );
				
				//Pass this bean to the save method
				
				countrySVC.save(country=data2Bean);	
				
				expect( data2Bean.getCountryCD() ).toBe( mock2Bean.getCountryCD() );
				expect( data2Bean.getCountryName() ).toBe( mock2Bean.getCountryName() );
				expect( data2Bean.getCountryCurrencyCD() ).toBe( mock2Bean.getCountryCurrencyCD() );
			
				});

		it("can delete a country with no referential integrity constraint", function(){	

				// Mock a new entity bean

				var mockBean = createMock("models.Country");	
				
				// Create a new country record for the purpose of that test.
				// This new country is not constrained and can therefore be deleted.
        		
        		mockBean.setCountryCD("AA"); 
        		mockBean.setCountryName("TEST"); 
				mockBean.setCountryCurrencyCD("EUR"); 
				
				// Simulate FORM data inserts
				
				var insertFormData = structNew();
				
				insertFormData.countryCD = "AA";
				insertFormData.countryName = "TEST";
				insertFormData.countryCurrencyCD = "EUR";
				
				var dataBean = createObject('component', 'models.Country').init(
				argumentCollection=insertFormData);
				
				// Populate the bean with the new record above. 
				
				var sNewCD = countrySVC.create(country=dataBean);
				dataBean.setCountryCD(sNewCD);
				
				// Verify that the record exists before delete
				
				var ExistBeforeDelete = countrySVC.exists(country=dataBean);
				expect ( ExistBeforeDelete ).toBe ( true );

				// Expect the newly created record to match mockBean

				expect( dataBean.getCountryCD() ).toBe( mockBean.getCountryCD() );
				expect( dataBean.getCountryName() ).toBe( mockBean.getCountryName() );
				expect( dataBean.getCountryCurrencyCD() ).toBe( mockBean.getCountryCurrencyCD() );

				// Delete this record
				
				countrySVC.delete(sNewCD); 
				
				// Verify that this record is no longer there
				
				var ExistAfterDelete = countrySVC.exists(country=dataBean);
				expect ( ExistAfterDelete ).toBe ( false );
				expect( dataBean ).ToBeEmpty;
								
				});

		it("cannot delete a country referencing a child record", function(){	
				
				// This test must return a database error: SqlState = 23000 , ErrorCode = 1451
				// Cannot delete or update a parent row: a foreign key constraint fails. 
				// referenced tables are:
				// 1 - tab_city  
				
				try {
				
				countrySVC.delete("FR");
				
				} catch(DBdeleteError e) {
					
				expect( e.Message ).toInclude ( "23000:", "FOREIGN KEY CONSTRAINT" );	
				
				}
				
				}); 

		it("can get all country records", function(){
					
				// Create a new instance of MockQuery for the purpose of this test		
				var mockQuery = countrySVC.getAllCountries();
				
				// Empty the query result set	
				var qCountries="";
				
				// Query all country records found in the table
				qCountries = countrySVC.getAllCountries();
				//debug(qCountries);
				
				// This test must pass.
				// expect the query result to return a matching record count.
				// and at least the approximate number of records.
				
				// Get all records
				
				expect( mockQuery.recordcount ).toBe ( qCountries.recordcount );
				expect( mockQuery.recordcount ).toBeGTE ( 1 );
				
				});

		it("can get an array of all country records", function(){
			
				// Create a new instance of MockQuery for the purpose of this test		
				var mockQuery = countrySVC.getAllCountries();
				
				// Create an empty array of countries	
				var aCountries = arrayNew(1);
				
				// retrieve an array of structures to list of all countries in the table
				aCountries = countrySVC.countryArrayList();
				//debug(aCountries);
				
				// Confirm that the returned object is an array
				var bool = isArray(aCountries);
				expect( bool ).toBe(true);
				
				// Get all records
				
				expect( arraylen(aCountries)).toBe ( mockQuery.recordcount );
				expect( arraylen(aCountries)).toBeGTE ( 5 );
				
				});		

		it("can filter country data by country name", function(){
					
				// Create a new instance of MockQuery for the purpose of this test		
				var mockQuery = countrySVC.filterByCountryName("S","LIKE");
				
				// Empty the query result set	
				var qCountries="";
				
				// Query country records by country name
				qCountries = countrySVC.filterByCountryName("S","LIKE");
				//debug(qCountries);
				
				// This test must pass.
				// expect the query result to return one or multiple records
				// because of the default "LIKE" SQL operator used in the query
				
				expect( mockQuery.recordcount ).toBe ( qCountries.recordcount );
				expect( mockQuery.recordcount ).toBeGTE ( 1 );
				
				});

		it("can filter country data by currency code", function(){
				
				// Create a new instance of MockQuery for the purpose of this test		
				var mockQuery = countrySVC.filterByCurrencyCode("EUR","=");
				
				// Empty the query result set	
				var qCountries="";
				
				// Query country records matching the filtered code
				qCountries = countrySVC.filterByCurrencyCode("EUR","=");
				debug(qCountries);

				// This test must pass.
				// expect the query result to return one or multiple records
				
				expect( mockQuery.recordcount ).toBe ( qCountries.recordcount );
				expect( mockQuery.recordcount ).toBeGTE ( 2 );
				
				});			

		it("can filter country data by country code", function(){
			
				// Create a new instance of MockQuery for the purpose of this test		
				var mockQuery = countrySVC.filterByCountryCode("US","<>");
				
				// Empty the query result set	
				var qCountries="";
				
				// Query country records by code excluding the filtered code
				qCountries = countrySVC.filterByCountryCode("US","<>");
				//debug(qCountries);

				// This test must pass.
				// expect the query result to return one or multiple records
				
				expect( mockQuery.recordcount ).toBe ( qCountries.recordcount );
				expect( mockQuery.recordcount ).toBeGTE ( 2 );
				
				});			

		});

	}

}
