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

		describe( "City Service test suite", function() {
			
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

						// Empty the databean target instance after each specification run
						var databean = structNew();
						var data2bean = structNew();
					 }
				}
		   } );

		   it("can read a city record", function(){	

			// Mock a new entity bean
			var mockBean = createMock("models.city");

			mockBean.setCityID(8); 
			mockBean.setCityName("BANGKOK");
			mockBean.setCityCD("");
			mockBean.setCityCountryCD("TH");
			
			// Populate a data bean with the data returned by the read method.
			// expect mockBean to match dataBean
			
			var databean = citySVC.read(8);

			// Verify that the dataBean exists

			var cityExists = citySVC.exists(dataBean);
			expect ( cityExists ).toBe( true );

			// debug(databean.getMemento());
			// debug(databean.isLoaded());

			// Expect dataBean to match mockBean
			
			expect( databean.getCityID() ).toBe( mockBean.getCityID() );
			expect( databean.getCityName() ).toBe( mockBean.getCityName() );
			expect( databean.getCityCountryCD() ).toBe( mockBean.getCityCountryCD() );
			expect( databean.getCityCD() ).toBe( mockBean.getCityCD() );
			
			});	   

			it("can create a city record", function(){	
						
				// Mock a new entity bean
				var mockBean = createMock("models.city");
        		
        		mockBean.setCityName("TEST");
				mockBean.setCityCD("");
        		mockBean.setCityCountryCD("IT"); 
				
				// Simulate FORM data inserts
				
				var insertFormData = structNew();
				
				insertFormData.cityName = "TEST";
				insertFormData.cityCountryCD = "IT";
				insertFormData.cityCD = "";
				
				var dataBean = createObject('component', 'models.city').init(
				argumentCollection=insertFormData);
				
				// Populate dataBean with the data returned by the create method.
				// expect mockBean to match dataBean
				
				var iNewID = citySVC.create(city=dataBean);
				dataBean.setCityID(iNewID);

				// Verify that the dataBean exists

				var cityExists = citySVC.exists(dataBean);
				expect ( cityExists ).toBe( true );

				// debug(databean);
				// debug(databean.isLoaded());

				// Expect dataBean to match mockBean
				
				expect( dataBean.getCityID() ).toBe( iNewID );
				expect( dataBean.getCityName() ).toBe( mockBean.getCityName() );
				expect( dataBean.getCityCountryCD() ).toBe( mockBean.getCityCountryCD() );
				expect( dataBean.getCityCD() ).toBe( mockBean.getCityCD() );
				
				});

			it("can duplicate a city name as long as it is not in the same country", function(){	
						
				// This test must pass.
				// PARIS, FRANCE and PARIS, TEXAS, USA are both valid entries
				
				// Mock a new entity bean
				var mockBean = createMock("models.city");

        		mockBean.setCityName("PARIS");
        		mockBean.setCityCountryCD("US");
        		mockBean.setCityCD("");
				
				// Simulate FORM data inserts
				
				var insertFormData = structNew();
				
				insertFormData.CityName = "PARIS";
				insertFormData.CityCountryCD = "US";
				insertFormData.CityCD = "";
				
				var dataBean = createObject('component', 'models.city').init(
				argumentCollection=insertFormData);
				
				// Populate dataBean with the data returned by the create method.
				// expect mockBean to match dataBean
				
				var iNewID = citySVC.create(city=dataBean);
				dataBean.setCityID(iNewID);

				//debug(databean);

				// Verify that the dataBean exists

				var cityExists = citySVC.exists(dataBean);
				expect ( cityExists ).toBe( true );

				// Expect dataBean to match mockBean
				
				expect( dataBean.getCityID() ).toBe( iNewID );
				expect( dataBean.getCityName() ).toBe( mockBean.getCityName() );
				expect( dataBean.getCityCountryCD() ).toBe( mockBean.getCityCountryCD() );
				expect( dataBean.getCityCD() ).toBe( mockBean.getCityCD() );
				
				});	

			it("cannot create a city with the name of an existing one within the same country", function(){	
						
				// There is only one city with the name ROME in Italy
				
				// Simulate FORM data inserts
				
				var insertFormData = structNew();
				
				insertFormData.cityName = "ROME"; // City already exists
				insertFormData.cityCountryCD = "IT";
				insertFormData.cityCD = "";
				
				var dataBean = createObject('component', 'models.city').init(
				argumentCollection=insertFormData);
				
				// This test must fail.
				// a new city cannot be given an existing name (in the same country).
				
				try {
					
				var iNewID = citySVC.create(city=dataBean);
				dataBean.setCityID(iNewID);
				
				} catch(DBinsertError e) {
					
				// This test must return a database error: SqlState = 23000 , ErrorCode = 1062
				// Duplicate entry for composite key 'UNIQUE'. 

				expect( e.Message ).toInclude ( "23000:", "UNIQUE" );	
					
				} 
				
				});			

			it("can update a city record provided the city name is not duplicated", function(){	
						
				// Mock a new entity bean
				var mockBean = createMock("models.city");
        		
        		mockBean.setCityID(8);
        		mockBean.setCityName("TEST");
        		mockBean.setCityCountryCD("FR");
        		mockBean.setCityCD("ABC");
				
				// Load a databean with actual data (before update)
				
				var dataBean = citySVC.read(8);

				// Verify that the dataBean exists

				var cityExists = citySVC.exists(dataBean);
				expect ( cityExists ).toBe( true );
				
				//Simulate FORM data update
				
				var editFormData = structNew();
				
				editFormData.cityName = "TEST";
				editFormData.cityCountryCD = "FR";
				editFormData.cityCD = "ABC";
				
				//Set the updated FORM values into the databean object.
				
				dataBean.setCityName(editFormData.cityName);
				dataBean.setCityCountryCD(editFormData.cityCountryCD);
				dataBean.setCityCD(editFormData.cityCD);
				
				//Pass this bean to the update method
				
				citySVC.update(city=dataBean);

				//debug(databean.getMemento());
				
				// This test must pass.
				// Populate dataBean with the data returned by the create method.
				// expect mockBean to match dataBean
				
				expect( dataBean.getCityName() ).toBe( mockBean.getCityName() );
				expect( dataBean.getCityCountryCD() ).toBe( mockBean.getCityCountryCD() );
				expect( dataBean.getCityCD() ).toBe( mockBean.getCityCD() );
				
				});

			it("cannot update a city with a name that already exists in the same country", function(){	
				
				// PARIS already exists in France and cannot be duplicated
				// Load a databean with actual data (before update)
				
				var dataBean = citySVC.read(2); 

				// Verify that the dataBean exists

				var cityExists = citySVC.exists(dataBean);
				expect ( cityExists ).toBe( true );
				
				//Simulate FORM data update
				
				var editFormData = structNew();
				
				editFormData.cityName = "PARIS"; // City already exists in France
				editFormData.cityCountryCD = "FR";
				editFormData.cityCD = "";

				//Set the updated FORM values into the databean object.
				
				dataBean.setCityName(editFormData.cityName);
				dataBean.setCityCountryCD(editFormData.cityCountryCD);
				dataBean.setCityCD(editFormData.cityCD);

				// This test must fail.
				// an distinct city record cannot be updated with an existing city name.
				
				try {
					
				citySVC.update(city=dataBean);
				
				} catch(DBupdateError e) {
					
				// This test must return a database error: SqlState = 23000 , ErrorCode = 1062
				// Duplicate entry for composite key 'UNIQUE'. 

				expect( e.Message ).toInclude ( "23000:", "UNIQUE" );	
					
				} 
				
				});

			it("can save [UPSERT] a city record", function(){	
				
				// This test creates a new city in the table or updates an existing one.		
				// Load an instance of mockBean with the expected data to match

				// Mock a new entity bean
				var mockBean = createMock("models.city");		 
				
				// Test an INSERT with a new city.
				
				mockBean.setCityName("TEST");
        		mockBean.setCityCountryCD("AU");
        		mockBean.setCityCD("");  
				
				// Simulate FORM data inserts
				
				var insertFormData = structNew();
				
				insertFormData.cityName = "TEST";
				insertFormData.cityCountryCD = "AU";
				insertFormData.cityCD = "";
				
				var dataBean = createObject('component', 'models.city').init(
				argumentCollection=insertFormData);

				// Test that the databean does not have an existing cityID, for the SAVE function
				// to call the appropriate method in the service (CREATE instead of UPDATE).

				var cityExists = citySVC.exists(dataBean);
				expect ( cityExists ).toBe( false );
				
				// This test must pass.
				// expect a new city record to be inserted that matches the above test record
				
				var iNewID = citySVC.save(city=dataBean);
				dataBean.setCityID(iNewID);
				
				expect( dataBean.getCityID() ).toBe( iNewID );
				expect( dataBean.getCityName() ).toBe( mockBean.getCityName() );
				expect( dataBean.getCityCountryCD() ).toBe( mockBean.getCityCountryCD() );
				expect( dataBean.getCityCD() ).toBe( mockBean.getCityCD() );
				
				// Test an UPDATE with an existing city

				// Mock a new entity bean
                var mock2Bean = createMock("models.city");	
				
				mock2Bean.setCityID(8);
        		mock2Bean.setCityName("BANGKOK");
        		mock2Bean.setCityCountryCD("TH");
        		mock2Bean.setCityCD("BKK"); 
				
				// Load another data bean with existing data (before update)
				
				var data2Bean = citySVC.read(8);

				//Simulate FORM data update
				
				var editFormData = structNew();
				
				editFormData.cityName = "BANGKOK";
				editFormData.cityCountryCD = "TH";
				editFormData.cityCD = "BKK";
				
				//Set the updated FORM values into the data2bean object.
				
				data2Bean.setCityName(editFormData.cityName);
				data2Bean.setCityCountryCD(editFormData.cityCountryCD);
				data2Bean.setCityCD(editFormData.cityCD);

				// Now, make sure that cityID exists for data2Bean

				var cityExists = citySVC.exists(data2Bean);
        		expect ( cityExists ).toBe( true );
				
				//Pass this bean to the save method
				
				citySVC.save(city=data2Bean);	
				
				expect( data2Bean.getCityName() ).toBe( mock2Bean.getCityName() );
				expect( data2Bean.getCityCountryCD() ).toBe( mock2Bean.getCityCountryCD() );
				expect( data2Bean.getCityCD() ).toBe( mock2Bean.getCityCD() );
			
				});

			it("can delete a city with no referential integrity constraint", function(){	
				
				// Mock a new entity bean

				var mockBean = createMock("models.city");	
				
				// Create a new city record for the purpose of that test.
				// This new city is not a foreign key used in a child record and can therefore be deleted. 
        		
        		mockBean.setCityName("TEST");
        		mockBean.setCityCountryCD("US");
        		mockBean.setCityCD("");
				
				// Simulate FORM data inserts
				
				var insertFormData = structNew();
				
				insertFormData.cityName = "TEST";
				insertFormData.cityCountryCD = "US";
				insertFormData.cityCD = "";
				
				var dataBean = createObject('component', 'models.city').init(
				argumentCollection=insertFormData);
				
				// Populate the bean with the new record above. 
				
				var iNewID = citySVC.create(city=dataBean);

				dataBean.setCityID(iNewID);

				// Now that it is generated, set the cityID in MockBean

				mockBean.setCityID(iNewID);

				// Expect the newly created record to match mockBean

				expect( mockBean.getCityID()).toBe ( iNewID );
				expect( mockBean.getCityName()).toBe ( "TEST" );
				expect( mockBean.getCityCountryCD()).toBe ( "US" );
				expect( mockBean.getCityCD()).toBe ( "" );

				// Verify that the record exists before delete
				
				var ExistBeforeDelete = citySVC.exists(city=dataBean);
				expect ( ExistBeforeDelete ).toBe ( true );

				// Delete this record
				
				citySVC.delete(iNewID); 
				
				// Verify that this record is no longer there
				
				var ExistAfterDelete = citySVC.exists(city=dataBean);
				expect ( ExistAfterDelete ).toBe ( false );
				expect( dataBean ).ToBeEmpty;
								
				
				});

			it("cannot delete a city referencing a child record", function(){	
				
				// This test must return a database error: SqlState = 23000 , ErrorCode = 1451
				// Cannot delete or update a parent row: a foreign key constraint fails.
				// referenced tables are:
				// 1 - tab_airport

				var dataBean = citySVC.read(1);

				// Verify that the record exists before delete
				
				var ExistBeforeDelete = citySVC.exists(city=dataBean);
				expect ( ExistBeforeDelete ).toBe ( true );
				
				try {
				
				// Cannot delete the city ID=1 (NEW YORK has two airports)
				citySVC.delete(1);

				
				} catch(DBdeleteError e) {
				
				expect( e.Message ).toInclude ( "23000:", "FOREIGN KEY CONSTRAINT" );		
					
				}
				
				}); 

			it("can get all city records", function(){
					
				// Create a new instance of MockQuery for the purpose of this test		
				var mockQuery = citySVC.getAllCities();
				
				// Empty the query result set	
				var qCities="";
				
				// Query all city records found in the table
				qCities = citySVC.getAllCities();
				//debug(qCities);
				
				// Get all records
				
				expect( qCities.recordcount ).toBe ( mockQuery.recordcount );
				expect( qCities.recordcount ).toBeGTE ( 5 );
				
				});

			it("can get an array of all city records", function(){
					
					// Create a new instance of MockQuery for the purpose of this test		
					var mockQuery = citySVC.getAllCities();
					
					// Create an empty array of cities	
					var aCities = arrayNew(1);
					
					// retrieve an array of structures to list of all the cities in the table
					aCities = citySVC.cityArrayList();
					//debug(aCities);
					
					// Confirm that the returned object is an array
					var bool = isArray(aCities);
					expect( bool ).toBe(true);
					
					// Get all records
					
					expect( arraylen(aCities)).toBe ( mockQuery.recordcount );
					expect( arraylen(aCities)).toBeGTE ( 5 );
					
					});
		

			it("can filter cities by city name", function(){
				
				// Create a new instance of MockQuery for the purpose of this test		
				var mockQuery = citySVC.filterByCityName("PARIS","LIKE");
				
				// Empty the query result set	
				var qCities="";
				
				// Query city records by city name
				qCities = citySVC.filterByCityName("PARIS","LIKE");
				
				// This test must pass.
				// expect the query result to return one or multiple records
				// because of the default "LIKE" SQL operator used in the query
				
				expect( qCities.recordcount ).toBe ( mockQuery.recordcount );
				expect( qCities.recordcount ).toBeGTE ( 1 );
				
				});

			it("can filter cities by their country code", function(){
				
				// Create a new instance of MockQuery for the purpose of this test		
				var mockQuery = citySVC.filterByCityCountryCode("AU","=");
				
				// Empty the query result set	
				var qCities="";
				
				// Query city records by their country code
				qCities = citySVC.filterByCityCountryCode("AU","=");
				
				// This test must pass.
				// expect the query result to return one or multiple records
				// because of the default "LIKE" SQL operator used in the query
				
				expect( qCities.recordcount ).toBe ( mockQuery.recordcount );
				expect( qCities.recordcount ).toBeGTE ( 1 );
				
				});

			it("can filter cities not matching a city ID", function(){
				
				// Create a new instance of MockQuery for the purpose of this test		
				var mockQuery = citySVC.filterByCityID(8,"<>");
				
				// Empty the query result set	
				var qCities="";
				
				// Query all city records excluding the filtered ID
				qCities = citySVC.filterByCityID(8,"<>");
				//debug(qCities);
				
				// This test must pass.
				// expect the query result to return one or multiple records
				
				expect( qCities.recordcount ).toBe ( mockQuery.recordcount );
				expect( qCities.recordcount ).toBeGTE ( 5 );
				
				});		


		});

	}

}
