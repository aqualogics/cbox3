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

		describe( "Load XML schema test suite", function() {
			beforeEach( function( currentSpec ) {
				setup();
				model = getInstance( "models.xml.LoadXMLschema" );
			
				// Reset the schema path parameters

			var fieldNamesPath = "";
			var tableNamePath = "";
			var primaryKeyPath = "";
			var secondaryKeyPath = "";
			var sortIndexPath = "";
		
			// Empty the databean target instance after each specification run
			
			var databean = "";

			} );

		// REFERENCES	

		it("can load the Currency schema", function(){	

			// Map the schema path to the function arguments

			var fieldNamesPath = "/schema/model[1]/entity[1]/propertyName/propertyValue/@name";
			var tableNamePath = "/schema/model[1]/entity[1]/@name";
			var primaryKeyPath = "/schema/model[1]/entity[1]/propertyName[1]/propertyValue/@name";
			var secondaryKeyPath = "";
			var sortIndexPath ="/schema/model[1]/entity[1]/propertyName[2]/propertyValue/@name";

			// Load the schema data calling the LoadXMLSchema model component
			
			var databean = StructNew();
			databean = model.schemaDataDAO(fieldNamesPath,tableNamePath,primaryKeyPath,secondaryKeyPath,sortIndexPath);

			//debug(databean);
	
			// Verify that the init arguments for Base service are loaded
				
			expect(databean.fieldNameList).toBe("cur_currency_cd,cur_currency_nm");
			expect(databean.tableName).toBe("tab_currency");
			expect(databean.primaryKeyName).toBe("cur_currency_cd");
			expect(databean.secondaryKeyName).toBe("");
			expect(databean.defaultOrderBy).toBe("cur_currency_nm");

			});

			it("can load the City schema", function(){	

			// Map the schema path to the function arguments

			var fieldNamesPath = "/schema/model[1]/entity[2]/propertyName/propertyValue/@name";
			var tableNamePath = "/schema/model[1]/entity[2]/@name";
			var primaryKeyPath = "/schema/model[1]/entity[2]/propertyName[1]/propertyValue/@name";
			var secondaryKeyPath = "";
			var sortIndexPath ="/schema/model[1]/entity[2]/propertyName[2]/propertyValue/@name";

			// Load the schema data calling the LoadXMLSchema model component
			
			var databean = StructNew();
			databean = model.schemaDataDAO(fieldNamesPath,tableNamePath,primaryKeyPath,secondaryKeyPath,sortIndexPath);

			//dump(databean);

			// Verify that the init arguments for Base service are loaded
				
			expect(databean.fieldNameList).toBe("cty_city_id,cty_city_nm,cty_city_cd,cty_country_cd");
			expect(databean.tableName).toBe("tab_city");
			expect(databean.primaryKeyName).toBe("cty_city_id");
			expect(databean.secondaryKeyName).toBe("");
			expect(databean.defaultOrderBy).toBe("cty_city_nm");

			});

			it("can load the Country schema", function(){	

			// Map the schema path to the function arguments

			var fieldNamesPath = "/schema/model[1]/entity[3]/propertyName/propertyValue/@name";
			var tableNamePath = "/schema/model[1]/entity[3]/@name";
			var primaryKeyPath = "/schema/model[1]/entity[3]/propertyName[1]/propertyValue/@name";
			var secondaryKeyPath = "";
			var sortIndexPath ="/schema/model[1]/entity[3]/propertyName[2]/propertyValue/@name";

			// Load the schema data calling the LoadXMLSchema model component
			
			var databean = StructNew();
			databean = model.schemaDataDAO(fieldNamesPath,tableNamePath,primaryKeyPath,secondaryKeyPath,sortIndexPath);

			//dump(databean);

			// Verify that the init arguments for Base service are loaded
				
			expect(databean.fieldNameList).toBe("cnt_country_cd,cnt_country_nm,cnt_currency_cd");
			expect(databean.tableName).toBe("tab_country");
			expect(databean.primaryKeyName).toBe("cnt_country_cd");
			expect(databean.secondaryKeyName).toBe("");
			expect(databean.defaultOrderBy).toBe("cnt_country_nm");

			});	
			
		it("can load the Airport schema", function(){	

			// Map the schema path to the function arguments

			var fieldNamesPath = "/schema/model[1]/entity[4]/propertyName/propertyValue/@name";
			var tableNamePath = "/schema/model[1]/entity[4]/@name";
			var primaryKeyPath = "/schema/model[1]/entity[4]/propertyName[1]/propertyValue/@name";
			var secondaryKeyPath = "";
			var sortIndexPath ="/schema/model[1]/entity[4]/propertyName[2]/propertyValue/@name";

			// Load the schema data calling the LoadXMLSchema model component
			
			var databean = StructNew();
			databean = model.schemaDataDAO(fieldNamesPath,tableNamePath,primaryKeyPath,secondaryKeyPath,sortIndexPath);

			//dump(databean);

			// Verify that the init arguments for Base service are loaded
				
			expect(databean.fieldNameList).toBe("gtw_airport_cd,gtw_airport_nm,gtw_city_id");
			expect(databean.tableName).toBe("tab_airport");
			expect(databean.primaryKeyName).toBe("gtw_airport_cd");
			expect(databean.secondaryKeyName).toBe("");
			expect(databean.defaultOrderBy).toBe("gtw_airport_nm");

			});	

		});
	}
}
