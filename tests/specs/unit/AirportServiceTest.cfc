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

		describe( "Airport Service test suite", function() {
			
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

						// Empty the databean target instance after each specification run
						var databean = structNew();
						var data2bean = structNew();
					 }
				}
		   } );

		it("can read an airport record", function(){	

				// Mock a new entity bean
				var mockBean = createMock("models.Airport");

        		mockBean.setAirportCD("BCN"); 
        		mockBean.setAirportName("BARCELONA AIRPORT");
				mockBean.setAirportCityID(5);
        		
				// Populate a data bean with the data returned by the read method.
				// expect mockBean to match dataBean

				databean = airportSVC.read("BCN");

				// debug(databean.getMemento());
				// debug(databean.isLoaded());

				// Verify that the airport object exists
				
				var isFound = airportSVC.exists(databean);
				expect ( isFound ).toBe( true );
				//debug(isFound);

				expect( databean.getAirportCD() ).toBe( mockBean.getAirportCD() );
				expect( databean.getAirportName() ).toBe( mockBean.getAirportName() );
				expect( databean.getAirportCityID() ).toBe( mockBean.getAirportCityID() );
				
			});	

		it("can create an airport record", function(){	
						
				// Mock a new entity bean
				var mockBean = createMock("models.Airport");
        		
        		mockBean.setAirportCD("AAA"); 
        		mockBean.setAirportName("TEST");
				mockBean.setAirportCityID(1);
				
				// Simulate FORM data inserts
				
				var insertFormData = structNew();
				
				insertFormData.airportCD = "AAA";
				insertFormData.airportName = "TEST";
				insertFormData.airportCityID = 1;
				
				var dataBean = createObject('component', 'models.Airport').init(
				argumentCollection=insertFormData);
				
				// Populate dataBean with the data returned by the create method.
				// expect mockBean to match dataBean
				
				var sNewCD = airportSVC.create(airport=dataBean);
				dataBean.setAirportCD(sNewCD);

				//debug(databean);

				// Verify that the dataBean exists

				var isFound = airportSVC.exists(dataBean);
				expect ( isFound ).toBe( true );
				//debug(isFound);
				
				expect( dataBean.getAirportCD() ).toBe( mockBean.getAirportCD() );
				expect( dataBean.getAirportName() ).toBe( mockBean.getAirportName() );
				expect( dataBean.getAirportCityID() ).toBe( mockBean.getAirportCityID() );
				
			});

		it("cannot duplicate an airport record", function(){	
				
				// Simulate FORM data inserts
				
				var insertFormData = structNew();
				
				insertFormData.airportCD = "JFK"; // Airport already exists
				insertFormData.airportName = "TEST";
				insertFormData.airportCityID = 1;
				
				var dataBean = createObject('component', 'models.Airport').init(
				argumentCollection=insertFormData);
				
				// This test must fail.
				
				try {
					
				var sNewCD = airportSVC.create(airport=dataBean);
				dataBean.setAirportCD(sNewCD);
				
				} catch(DBinsertError e) {
					
				// This test must return a database error: SqlState = 23000 , ErrorCode = 1062
				// Duplicate entry for composite key 'UNIQUE'. 

				expect( e.Message ).toInclude ( "23000:", "UNIQUE" );	
					
				} 
				
			});

		it("can update an airport record", function(){	
						
				// Mock a new entity bean
				var mockBean = createMock("models.Airport");
        		
        		mockBean.setAirportCD("JFK"); 
        		mockBean.setAirportName("TEST NY");
				mockBean.setAirportCityID(3); 
				
				// Load a databean with actual data (before update)
				
				var dataBean = airportSVC.read("JFK");

				// Verify that the dataBean exists

				var airportExists = airportSVC.exists(dataBean);
				expect ( airportExists ).toBe( true );
				
				//Simulate FORM data update
				
				var editFormData = structNew();
				
				editFormData.airportCD = "JFK";
				editFormData.airportName = "TEST NY";
				editFormData.airportCityID = 3;
				
				//Set the updated FORM values into the databean object.
				
				dataBean.setAirportName(editFormData.airportName);
				dataBean.setAirportCityID(editFormData.airportCityID);
				// debug(databean.getMemento());
				// debug(databean.isLoaded());
				
				//Pass this bean to the update method
				
				airportSVC.update(airport=dataBean);
				
				// This test must pass.
				// Populate dataBean with the data returned by the create method.
				// expect mockBean to match dataBean
				
				expect( dataBean.getAirportCD() ).toBe( mockBean.getAirportCD() );
				expect( dataBean.getAirportName() ).toBe( mockBean.getAirportName() );
				expect( dataBean.getAirportCityID() ).toBe( mockBean.getAirportCityID() );
				
				});

		it("can save [UPSERT] an airport record", function(){	
				
				// This test creates a new country in the table or updates an existing one.		
				// Load an instance of mockBean with the expected data to match

				// Mock a new entity bean
				var mockBean = createMock("models.Airport");		 
				
				// Test an INSERT with a new airport.
				
				mockBean.setAirportCD("AAA"); 
        		mockBean.setAirportName("TEST");
				mockBean.setAirportCityID(5);
				
				// Simulate FORM data inserts
				
				var insertFormData = structNew();
				
				insertFormData.airportCD = "AAA";
				insertFormData.airportName = "TEST";
				insertFormData.airportCityID = 5;
				
				var dataBean = createObject('component', 'models.Airport').init(
				argumentCollection=insertFormData);

				// Test that the databean does not have an existing primary key, for the SAVE function
				// to call the appropriate method in the service (CREATE instead of UPDATE).

				var airportExists = airportSVC.exists(dataBean);
				expect ( airportExists ).toBe( false );
				
				// This test must pass.
				// expect a new airport record to be inserted that matches the above test records
				
				var sNewCD = airportSVC.save(airport=dataBean);
				dataBean.setAirportCD(sNewCD);
				
				expect( dataBean.getAirportCD() ).toBe( sNewCD );
				expect( dataBean.getAirportName() ).toBe( mockBean.getAirportName() );
				expect( dataBean.getAirportCityID() ).toBe( mockBean.getAirportCityID() );
				
				// Test an UPDATE with an existing airport

				// Mock a new entity bean
                var mock2Bean = createMock("models.Airport");	
				
				mock2Bean.setAirportCD("FCO"); 
        		mock2Bean.setAirportName("ROME INT'L");
				mock2Bean.setAirportCityID(5);  
				
				// Load another data bean with existing data (before update)
				
				var data2Bean = airportSVC.read("FCO");

				//Simulate FORM data update
				
				var editFormData = structNew();
				
				editFormData.airportCD = "FCO";
				editFormData.airportName = "ROME INT'L";
				editFormData.airportCityID = 5;
				
				//Set the updated FORM values into the data2bean object.
				
				data2Bean.setAirportName(editFormData.airportName);
				data2Bean.setAirportCityID(editFormData.airportCityID);  

				// Now, make sure that airportCD exists for data2Bean

				var airportExists = airportSVC.exists(data2Bean);
        		expect ( airportExists ).toBe( true );
				
				//Pass this bean to the save method
				
				airportSVC.save(airport=data2Bean);	
				
				expect( data2Bean.getAirportCD() ).toBe( mock2Bean.getAirportCD() );
				expect( data2Bean.getAirportName() ).toBe( mock2Bean.getAirportName() );
				expect( data2Bean.getAirportCityID() ).toBe( mock2Bean.getAirportCityID() );
			
				});

		it("can delete an airport with no referential integrity constraint", function(){	

				// Mock a new entity bean

				var mockBean = createMock("models.Airport");	
				
				// Create a new airport record for the purpose of that test.
				// This new airport is not constrained and can therefore be deleted.
        		
        		mockBean.setAirportCD("AAA"); 
        		mockBean.setAirportName("TEST"); 
				mockBean.setAirportCityID(1); 
				
				// Simulate FORM data inserts
				
				var insertFormData = structNew();
				
				insertFormData.airportCD = "AAA";
				insertFormData.airportName = "TEST";
				insertFormData.airportCityID = 1;
				
				var dataBean = createObject('component', 'models.Airport').init(
				argumentCollection=insertFormData);
				
				// Populate the bean with the new record above. 
				
				var sNewCD = airportSVC.create(airport=dataBean);
				dataBean.setAirportCD(sNewCD);
				
				// Verify that the record exists before delete
				
				var ExistBeforeDelete = airportSVC.exists(airport=dataBean);
				expect ( ExistBeforeDelete ).toBe ( true );

				// Expect the newly created record to match mockBean

				expect( dataBean.getAirportCD() ).toBe( mockBean.getAirportCD() );
				expect( dataBean.getAirportName() ).toBe( mockBean.getAirportName() );
				expect( dataBean.getAirportCityID() ).toBe( mockBean.getAirportCityID() );

				// Delete this record
				
				airportSVC.delete(sNewCD); 
				
				// Verify that this record is no longer there
				
				var ExistAfterDelete = airportSVC.exists(airport=dataBean);
				expect ( ExistAfterDelete ).toBe ( false );
				expect( dataBean ).ToBeEmpty;
								
				});

		xit("cannot delete an airport referencing a child record", function(){	
				
				// This test must return a database error: SqlState = 23000 , ErrorCode = 1451
				// Cannot delete or update a parent row: a foreign key constraint fails. 
				// referenced tables are: 
				
				try {
				
				airportSVC.delete("CDG");
				
				} catch(DBdeleteError e) {
					
				expect( e.Message ).toInclude ( "23000:", "FOREIGN KEY CONSTRAINT" );	
				
				}
				
				}); 

		it("can get all airport records", function(){
					
				// Create a new instance of MockQuery for the purpose of this test		
				var mockQuery = airportSVC.getAllAirports();
				
				// Empty the query result set	
				var qAirports="";
				
				// Query all airport records found in the table
				qAirports = airportSVC.getAllAirports();
				//debug(qAirports);
				
				// This test must pass.
				// expect the query result to return a matching record count.
				// and at least the approximate number of records.
				
				// Get all records
				
				expect( mockQuery.recordcount ).toBe ( qAirports.recordcount );
				expect( mockQuery.recordcount ).toBeGTE ( 1 );
				
				});

		it("can get an array of all airport records", function(){
			
				// Create a new instance of MockQuery for the purpose of this test		
				var mockQuery = airportSVC.getAllAirports();
				
				// Create an empty array	
				var aAirports = arrayNew(1);
				
				// retrieve an array of structures to list of all airports in the table
				aAirports = airportSVC.airportArrayList();
				//debug(aAirports);
				
				// Confirm that the returned object is an array
				var bool = isArray(aAirports);
				expect( bool ).toBe(true);
				
				// Get all records
				
				expect( arraylen(aAirports)).toBe ( mockQuery.recordcount );
				expect( arraylen(aAirports)).toBeGTE ( 5 );
				
				});	
				
		it("can filter airport data by airport code", function(){
				
				// Create a new instance of MockQuery for the purpose of this test		
				var mockQuery = airportSVC.filterByAirportCode("SYD","<>");
				
				// Empty the query result set	
				var qAirports="";
				
				// Query airport records matching the filtered code
				qAirports = airportSVC.filterByAirportCode("SYD","<>");
				// debug(qAirports);

				// This test must pass.
				// expect the query result to return one or multiple records
				
				expect( mockQuery.recordcount ).toBe ( qAirports.recordcount );
				expect( mockQuery.recordcount ).toBeGTE ( 2 );
				
				});	

		it("can filter airport data by airport name", function(){
			
				// Create a new instance of MockQuery for the purpose of this test		
				var mockQuery = airportSVC.filterByAirportName("MONT","LIKE");
				
				// Empty the query result set	
				var qAirports="";
				
				// Query airport records by code excluding the filtered code
				qAirports = airportSVC.filterByAirportName("MONT","LIKE");
				//debug(qAirports);

				// This test must pass.
				// expect the query result to return one or multiple records
				
				expect( mockQuery.recordcount ).toBe ( qAirports.recordcount );
				expect( mockQuery.recordcount ).toBeGTE ( 1 );
				
				});		

		it("can filter airport data by city ID", function(){
					
				// Create a new instance of MockQuery for the purpose of this test		
				var mockQuery = airportSVC.filterByCityID(1,"=");
				
				// Empty the query result set	
				var qAirports="";
				
				// Query country records by country name
				qAirports = airportSVC.filterByCityID(1,"=");
				//debug(qAirports);
				
				// This test must pass.
				// expect the query result to return one or multiple records
				// because of the default "LIKE" SQL operator used in the query
				
				expect( mockQuery.recordcount ).toBe ( qAirports.recordcount );
				expect( mockQuery.recordcount ).toBeGTE ( 2 );
				
				});

		});

	}

}
