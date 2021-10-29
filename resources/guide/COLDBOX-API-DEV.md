# MERAPI: Coldbox API development

The purpose of this document is to guide through the steps of our API development.

> - First, we define a schema
> - Next, we build a model composed of entity and service components for which we create unit tests
> - Once our model is tested, we start building API handlers, for which we create integration tests
> - Next, we document our API and review the documentation with tools such as Open API (Swagger).
> - Finally we test the API responses as a result of data input via POSTMAN

## 1 - SCHEMA DEFINITION AND LOADING

Our approach assumes the existence of a legacy schema definition. It means that our tables' column naming convention differs from our entity object properties' naming convention and that, because of this, object property names are going to be mapped to tables' column names. Although a departure from Coldbox common practices, this approach will demonstrate Coldbox's flexibility in adapting to non-trivial modelling requirements. 

### Configure database access

>In the merapi database, create a user webuser identified by "yourPassword" with schema privileges
>limited to INSERT, SELECT, UPDATE and DELETE.

Update `config/Coldbox.cfc` by adding the following under custom settings:

// Custom settings

```
settings = {
    merapi = {
        type = "mysql",
        username = "webuser",
        name = "merapi"	
    }
};
```

Thanks to those settings now added in Coldbox.cfc, it is now possible to have any of our components connected to our database instance called `merapi` with the inclusion of a simple dependency injection:

> property name="dsn" inject="coldbox:setting:merapi";

### XML schema

In order to connect our components to our database schema, we have mapped our component properties to a table definition in a `models/xml/schema.xml` file. This mapping associates the column names of a table, defined as an entity, to their corresponding entity object property names.

We also created a `models/xml/LoadXMLschema.cfc` component to read this XML file when we invoke a parent model component called BaseService.cfc. A generic mapping structure called `subSetArgs` is returned by a
method that is made available in this parent component.

When a specific service component is invoked, it inherits `BaseService.cfc`. When a child service component is instantiated while calling this specific service constructor, an XPath method reads the schema.xml in order to find, dynamically, the values of the table name, the column (field) names, the primary key and other properties that are required by the service.

> NB: Please note that Coldbox **does not** require you to create an XML schema. We decided to do so in
> order to demonstrate how a legacy database schema could be easily mapped between model objects and
> table columns using distinct naming conventions, as well as using a mix of string and numeric ID 
> primary keys. 
> You could have as well adopted a Coldbox ORM or kept the same naming conventions between table columns
> and model objects, exclusively use numeric ID primary keys and, therefore, avoid the XML schema
> mapping, altogether.

### Update config/Wirebox.cfc

To ensure that the component can be simply called as "LoadXMLschema" instead of being called with its entire path (models/xml/LoadXMLschema), we need to update the Wirebox.cfc file configuration as follows:

```
// Map Bindings below
map("LoadXMLschema").to("models.xml.LoadXMLschema");
```

## 2 - BUILD THE MODEL

The models folder contains two types of files: `entity` components (such as City.cfc) and `service` components such as (CityService.cfc). All service components inherit from a BaseService.cfc component.

Entity and Service objects are both instantiated with an init() function (the constructor) found within their component definition:

- An entity component defines the properties of the object when instantiated.
- A service component defines all the methods required to interact with the object when instantiated.

The following models components must be created in the `models`folder:

For entities:

> - Airport.cfc,
> - City.cfc,
> - Country.cfc,
> - Currency.cfc,
> - User.cfc // automatically created with the installation of the API template

For services:

> - BaseService.cfc
> - AirportService.cfc
> - CityService.cfc
> - CountryService.cfc
> - CurrencyService.cfc
> - UserService.cfc // automatically created with the installation of the API template

### Unit tests

All our models files each have a corresponding test component located at the `tests/specs/unit` folder. 

We have created the following unit tests:

> - LoadSchemaTest.cfc
> - AirportTest.cfc / AirportServiceTest.cfc
> - CityTest.cfc / CityServiceTest.cfc
> - CountryTest.cfc / CountryServiceTest.cfc
> - CurrencyTest.cfc / CurrencyServiceTest.cfc
> - UserTest.cfc / UserServiceTest.cfc  // were automatically created with the template

Make sure that all these tests pass as you progress in your development.

## 3 - BUILD THE API

### 3.1 Configure the router

It is essential to add all the required API routes in config/Router.cfc. Note that order matters for the routing statements. Always place the most specific statement before the least specific ones for a given route. Here is what we should have for the currency API routing:

```
route( "/api/currency/:currencyCD" )
		.withAction( {
			GET    : "show",
			PUT    : "update",
			DELETE : "delete"
		} )
		.toHandler( "CurrencyAPI" );

route( "/api/currency" )
.withAction( {
    GET    : "index",
    POST   : "create"
} )
.toHandler( "CurrencyAPI" );

```

> NB: The `route-visualizer` module was automatically installed with the Coldbox REST API template.
> Launch it here to view all your routes: `http://127.0.0.1:<yourPortNumber>/route-visualizer`

### 3.2 Write the API handlers

We are going to write API handlers. They will be located in the `/handlers` folder and named as follows:

> - CurrencyAPI.cfc
> - CityAPI.cfc
> - CountryAPI.cfc
> - AirportAPI.cfc

The `resources/apidocs` folder contains the documentation of our API. It is structured as follows:

> - First we create a folder named `resources/apidocs/_responses`
> - This folder contains xxxx.404.json response files (one per handler)
> - Another folder is created for each handler such as `resources/apidocs/currency`
> - It contains sub-folders named index, show, create, update and delete (for each handler action)

Thanks to `annotations`, each handler is mapped to the above folders, pointing to the files and responses located in `resources/apidocs`, hence building the API documentation. 
Here is an example for CurrencyAPI.cfc:

```
* Returns a list of currencies
* @x-route (GET) /api/currency
* @response-default ~currency/index/responses.json##200

function index( event, rc, prc ) cache=true cacheTimeout=60 {
    // the handler's index action code goes here
}
```

> - The function index of CurrencyAPI.cfc returns a list of currencies
> - The API documentation is made with annotations such as `@response-default` or `@x-route`.
> - This points within the file /resources/apidocs/currency/index/responses.json for response 200
> - The mapping to /resources/apidocs/currency is implemented with the tilde sign (~currency)

Using the same logic, the show action is implemented as follows:

```
* Display (show) a single currency
* @x-route (GET) /api/currency/:currencyCD
* @x-parameters ~currency/show/parameters.json##parameters
* @response-200 ~currency/show/responses.json##200
* @response-404 resources/apidocs/_responses/currency.404.json

function show( event, rc, prc ) cache=true cacheTimeout=60 {
    // the handler's show action code goes here
}
```

The same pattern is also used here for the create action:

```
* Creates a new Currency
* @x-route (POST) /api/currency
* @requestBody  ~currency/create/requestBody.json
* @response-200 ~currency/create/responses.json##200
* @response-400 ~currency/create/responses.json##400
* @response-500 ~currency/create/responses.json##500

function create( event, rc, prc ){
    // the handler's create action code goes here
}
```

Here as well, for the update action:

```
* Update a Currency
* @x-route (PUT) /api/currency/:currencyCD
* @requestBody ~currency/update/requestBody.json
* @response-200 ~currency/update/responses.json##200
* @response-400 ~currency/update/responses.json##400
* @response-404 resources/apidocs/_responses/currency.404.json

function update( event, rc, prc ){
    // the handler's update action code goes here
 }
 ```

And finally, for the delete action:

```
* Delete a Currency
* @x-route (DELETE) /api/currency/:currencyCD
* @x-parameters ~currency/delete/parameters.json##parameters
* @response-200 ~currency/delete/responses.json##200
* @response-404 resources/apidocs/_responses/currency.404.json

function delete( event, rc, prc ){ 
    // the handler's delete action code goes here
}

```

The API documentation is assembled with the notations we added above, at the same time we built the code for the API handler. You'll see the value of this work when we run `cbSwagger`in paragraph 3.4, and, even better, when we import all this documentation as a yaml file in POSTMAN in paragraph 3.5, to test our API. 

### 3.3 API handlers integration tests

All the API handlers' integration tests are found in the `tests/specs/integration`folder. To the default tests (AuthTests.cfc and EchoTests.cfc), that came pre-installed with the Coldbox API template, you should now have the following new tests:

> - CurrencyAPITest.cfc
> - CityAPITest.cfc
> - CountryAPITest.cfc
> - AiportAPITest.cfc

 Ensure that all your integration tests pass.

### 3.4 Documenting the API

To build the API documentation, we have associated pointers with our handlers'actions. They are pointing to files located in the `resources/apidocs` folder.

The `cbSwagger` module was installed automatically when initially running the Coldbox API template. Swagger, now known as openAPI, is used to document our API. 

> Update config/coldbox.cfc
> Under module settings for cbswagger servers, replace the development server port number with your 
> actual port number (line 214).

Just hit the cbSwagger route at `http://127.0.0.1:<yourportnumber>/cbswagger` to trigger the API data default json format to be sent to output.

Go to `https://swagger.io/tools/swagger-editor/` , download the Swagger editor zip file and extract it to a SwaggerEditor folder on your desktop. Now click on the index.html file within that folder to load the editor in your browser. Clear the content (PetStore example) loaded by default in the editor, select all of the json format output that you generated at `http://127.0.0.1:<yourportnumber>/cbswagger`. Then paste all that data in the editor. Say YES when you are prompted to convert the json data placed in the editor to `yaml` format. The complete API found under `resources/apidocs` is now documented. This documentation comes from the files we added under the `resources/apidocs` folder in paragraph 3.2.

In the Swagger editor on line 17, replace the development server URL with the port number on which the API actually runs. Now select your server from the drop-down select box found on top of the Merapi REST template output. You can see that all the default API operations are now displayed. You may now try them out one by one to check the data returned by your API. Save a copy of the converted `openapi.yaml` file to `resources/apidocs` as your latest API documentation backup file.

### 3.5 Testing the API with POSTMAN

Sign-up for free at https://www.postman.com to download and install a POSTMAN client. We are running POSTMAN v9.0.5. Access your workspace in the POSTMAN client.

1 - Create a new environment called `MerapiEnvironment`.

> - Create a variable called "baseUrl" pointing to `http://127.0.0.1:<yourPortNumber>`. 
> - Check your variable name, as it is case sensitive.

2 - Create a new collection:

> - Click import > File > OpenApi
> - Link this collection as `Testsuite`
> - Click import, and retrieve the `resources/apidocs/openapi.yaml` file that you created earlier

You should get a message confirming the import. Your entire API should now be made available to you for testing within POSTMAN. This simple feature justifies the additional effort involved in writing the annotations in the handler, and the response/example files in the resources/apidocs folder.

3 - Set the default environment for the collection

> - Select `MerapiEnvironment` as the applicable environment in the top-right corner of the workspace

#### 3.5.1 Testing the Currency API

First of all ensure that the Lucee server is running. Do not forget that your APIs are run against your database and that the records you are creating, updating or deleting with POSTMAN are not automatically rolled back.

> - RUN GET a list of currencies
> - Next to the GET operator, hover on {{baseUrl}} variable to ensure that the right server is called
> - Click `Send` - Ensure that a list is returned and that the response status returned is 200 ok 

> - RUN Create a new currency (200 ok response)
> - Click on Body, assign values to currencyCD / currencyName that do not exist such as "AAA" / "TEST"
> - Click Send - Ensure that the record was created and that the response status returned is 200 ok
> - Look up the tab_currency database table to verify that the new record was inserted.

> - RUN Create a new currency (500 MySQL insert error)
> - Click on Body, assign a value to currencyCD that already exists
> - Click Send - An error 500 MySQL insert error should be returned
> - The error message "Attempted duplicate record entry" is returned to you.
> - The message comes from the try/catch statement in the create action of the CurrencyAPI.cfc handler.  

> - RUN Display (show) a single currency (200 ok response)
> - Click on Params and go to path variables
> - For currencyCD value enter a currency code found in the database
> - Click Send - A 200 ok response message, together with the currency name is returned to you.

> - RUN Display (show) a single currency (4xx response)
> - Click on Params and go to path variables
> - For currencyCD value enter a currency code NOT found in the database
> - Click Send - A 404 ok response message "the requested currency does not exist" is returned to you.

> - RUN Update a currency (200 ok response)
> - Click on Params and go to path variables
> - For currencyCD value enter a currency code found in the database such as "AAA". 
> - Click on Body
> - For CurrencyCD value enter "AAA" (same as above in Params)
> - For currencyName value enter "TEST 123" to replace "TEST"
> - Click Send - A 200 ok "Currency was updated successfully" message is returned to you 

> - RUN Update a currency (4xx response)
> - Click on Params and go to path variables
> - Leave currencyCD value as "AAA"
> - Click on Body
> - For currencyCD value enter "AAA" (same as above in Params)
> - For currencyName value enter ""
> - Click Send - A 400 ok "invalid data received from client" - The currency name value is required.

> - RUN Update a currency (4xx response)
> - Click on Params and go to path variables
> - Set currencyCD value as "ZZZ"
> - Click on Body
> - For currencyCD value enter "ZZZ" (same as above in Params)
> - For currencyName value enter "ZZZ DOLLAR"
> - Click Send - A 404 ok "Record does not exist" is sent to you.

> - RUN Delete a currency (200 ok response)
> - Click on Params and go to path variables
> - For currencyCD value enter a the currency code "AAA" that we just created in the database
> - Click Send - A 200 ok response message "Currency was deleted successfully" is returned to you.
> - Verify that the deleted record is no longer found in the tab_currency table

> - RUN Delete a currency (4xx response)
> - Click on Params and go to path variables
> - For currencyCD value enter a the currency code "AAA" that we just deleted in the database
> - Click Send, you get a 404 response message "You are attempting to delete a record that does not exist"






