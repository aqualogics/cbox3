# The Merapi project

All the code for this project can be found on our github repository located at this URL:
https://github.com/aqualogics/cbox3

Intermediate code will be added for each section of our tutorial as a `cbox3.zip` archive that you can download as you progress through the course.

## A - Installation

We are starting with a clean GitLab repository that only contains a README.md file and a resources/guide folder that contains our documentation. We are now going to configure our project. 
It includes a `cbox3` folder where a Coldbox REST API template will be installed.

### A1 - Pre-requisites

[cbox3]

    - CommandBox shell must be available (type the `box` command to check its availability)
    - MySQL must have an empty database called `cbox3` that you can connect to with a MySQL client

```
It is assumed that all pre-requisites are satisfied by now in order to proceed with the project 
configuration.

```

### A2 - Install a Coldbox `cbox3` server app

```
// Go to your root project directory
cd cbox3

```

- Launch a terminal in VSCode within the `cbox3` folder.
- Start the Commandbox shell typing the `box` command.

Now, in the cbox3 folder, all commands assume that we are in the `commandbox` shell (unless stated otherwise). Find all Coldbox application templates here for your reference:
https://github.com/coldbox-templates

Read the README.md file in this project for a description of the REST template.
Now, install the RESTful API Coldbox template within the cbox3 folder.
Run the command: `coldbox create app name=cbox3 skeleton=rest`

Verify that your basic Coldbox API project is properly configured, 
run the command to start the server: `start` or `server start`

You should now see the API echo displaying some default JSON data output.
To stop the server, run the command: `stop`

### A3 - The `Merapi` project structure

The Merapi project should now be structured as follows:

```

├── cbox3
│   ├── README.md             
│   ├── coldbox              
│   ├── config         
│   ├── models           
│   ├── modules
|   ├── modules_app
|   ├── resources
|   ├── testbox
|   ├── tests          
                    
```

## B - Configure the Coldbox services

### B1 - Install additional Coldbox modules

In addition to modules that were already installed with the REST API template, we'll need
to install other modules needed by our application. You may refer to all the available Coldbox 
modules here: https://github.com/coldbox-modules

Within the CommandBox shell, install the following modules:

```
install cbsecurity@2.13 //  Module upgrade to leverage Refresh JWT tokens
install BCrypt // Coldbox encryption module
install cbswagger --savedev
install cfmigrations // See (1) for additional setup

```
(1) cfmigrations expects a `database/migrations` subfolder within the `resources` folder
in order to find the migrations components to run up or down. (See B-6.3 cfmigrations structure in box.json below)

Verify that all the above modules can now be found in the modules folder.

### B2 - Verify Coldbox.cfc settings

Ensure that the mementifier module also has a setting added to config/Coldbox.cfc file under `module settings`.

Just open your `config/Coldbox.cfc` and add the following settings into the `moduleSettings` struct under the `mementifier` key:

```js
// module settings - stored in modules.name.settings
moduleSettings = {
	mementifier = {
		// Turn on to use the ISO8601 date/time formatting on all processed date/time properites, else use the masks
		iso8601Format = false,
		// The default date mask to use for date properties
		dateMask      = "yyyy-MM-dd",
		// The default time mask to use for date properties
		timeMask      = "HH:mm:ss",
		// Enable orm auto default includes: If true and an object doesn't have any `memento` struct defined
		// this module will create it with all properties and relationships it can find for the target entity
		// leveraging the cborm module.
		ormAutoIncludes = true,
		// The default value for relationships/getters which return null
		nullDefaultValue = '',
        // Don't check for getters before invoking them
        trustedGetters = false,
		// If not empty, convert all date/times to the specific timezone
		convertToTimezone = ""
	}
}
```

### B3 - Update Application.cfc

In the root project, update the Application.cfc file by adding this line under Application properties:

`this.datasource = "cbox3";`

### B4 - Update the dot env file

A dot env file is needed to allow seamless access to the `cbox3` database instance schema, without leaking database access credentials outside the local development environment (make sure this file is added to the dot gitignore file). 
The dot env file uses "coldbox" as the default database instance, which means you need to replace this name with "cbox3", or whatever name you used for your environment and database instance.

NB: Pay particular attention to this file as it is critical for your installation and because many settings are either incorrect or not found in the dot environment file generated by default by the Coldbox API template. The settings highlighted below are essential for datasource (MySQL driver settings) and for cfmigrations (DB_SCHEMA) to work.

```

# ColdBox Environment
APPNAME=Merapi
ENVIRONMENT=development

# Database Information
DB_CONNECTIONSTRING=jdbc:mysql://127.0.0.1:3306/cbox3?useSSL=false&useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC&useLegacyDatetimeCode=true
DB_CLASS=com.mysql.cj.jdbc.Driver
DB_DRIVER=MySQL
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=cbox3
DB_SCHEMA=cbox3
DB_USER=root
DB_PASSWORD=yourPassword

# Lucee compatible database driver settings
DB_BUNDLENAME=com.mysql.cj
DB_BUNDLEVERSION=8.0.19

# JWT Information
JWT_SECRET=

# S3 Information
S3_ACCESS_KEY=
S3_SECRET_KEY=
S3_REGION=us-east-1
S3_DOMAIN=amazonaws.com

```

### B5 - Configure the CFML (Lucee) server

Your MySQL database **should have already been installed** and your MySQL client should connect 
successfully to a `cbox3` instance.

Depending on the last command we ran in paragraph A-2, we may already have our Coldbox server running. Verify this by typing the command `server list` at the commandbox prompt. Take note of the CF engine version and the port number automatically assigned upon server launch.

- `<server-version`: something like `lucee@5.3.8+201`, which refers to the current stable version of the Lucee engine
- `<Portnumber>`: somehing like `52019` which depends on your own installation 

We now need to pin our server engine version, otherwise commandbox will always upgrade with the latest stable version available on ForgeBox, the next time you start your server. This may not be what we want. We are therefore going to pin the CFML server version to the value of `<server-version>`.

#### B5.1 Edit server.json to pin your server to a port, an engine and a version

Make a backup of the server.json file before modifying it and stop the server with the command `stop` if it is running.
Now update server.json with what follows:

```sh
{
    "app":{
        "cfengine": "lucee@5.3.8+201"
    },

    "web":{
        "rewrites":{
            "enable":true
        },
        "http":{
            "port":52019
        },
        "name":"merapi"
    }    
}

```

#### B5.2 Re-start the server

```sh
stop or (server stop)
start or (server start)
server list

```
- In the server list output, verify that the server now boots your selected port and engine version.

Your MySQL database **should have already been installed** and your MySQL client should connect 
successfully to a `cbox3` instance.

#### B5.3 - Create a password to access Lucee server administration

Within the Commandbox shell, ensure that your Lucee server is started by typing the command: `server list`
A few seconds after starting the server, you should see a little Lucee icon on your browser's top bar.

- Launch the Lucee administrator

```sh
- Click the little Lucee icon on your browser top bar
- Go and select Open > Server Admin from the menu options
```

You will be required to set a password the first time you try to access the Lucee server admin.
Verify that you have `commandbox-cfconfig` installed by running the `list` command at the commandbox prompt. You should have this module available if you performed the template installation steps described in paragraph A3.

Otherwise, if you can't find it, proceed with the module installation: `install commandbox-cfconfig`.

Let's set a password for the Lucee administrator: `cfconfig set adminPassword=cbox3`
Now, you should have a confirmation that the password was set.

Re-start the server for the changes to take effect.

#### B5.4 - Verify Datasource / MySQL connection

Now you can get back to the Lucee server administrator and use the password you just created to login.

Once logged as Lucee administrator, go to Services > Datasource.
The "cbox3" datasource should have already been created by the Lucee engine based on the .cfconfig.json file settings that are read when the server re-starts. The .cfconfig.json reads its database connection parameters from the dot env file. Test the datasource connection.

If the test fails, delete and re-create a new datasource with the name `cbox3` and with a driver type of `mysql`. It should now work. The problem arose from a mis-match in the jdbc class driver name. The default .env file generated by the Coldbox API template uses a deprecated MySQL driver class.

If you choose a name other than "cbox3" for the datasource, remember to update Application.cfc accordingly (as per paragraph B-3). Stop and re-start your server for the changes to take effect. 

### B6 - Database schema migrations

Here we are going to use Schema builder migrations to manage our database schema. This feature is not provided by default with the installation of the Coldbox API template. While we already installed the `cfmigrations` module in paragraph B-1 above, some further configuration is needed to make it work.

#### B6.1 - Initiate the schema migration

Database migrations provide version control for your application's database. Changes to database schema are kept in timestamped files that are run `up` and `down`. In the `up` function, you describe the changes to apply (commit) your migration. In the `down` function, you describe the changes to undo (rollback) your migration.

```
NB: You can run migrations without having a server currently started.
```

Check whether `box.json` includes a **cfmigrations** structure. If it does not, run `migrate init` to create this structure.In order to track which migrations have been run, `cfmigrations` needs to install a table in your database called `cfmigrations`. 

At the commandbox prompt run the following command: `migrate install`.

For this to work, you need a line with `DB_SCHEMA=cbox3` in your dot env file, otherwise you may get a misleading message such as "cfmigrations table is already installed" while, in fact, it isn't.

Go to https://qb.ortusbooks.com/schema-builder/schema-builder to consult the documentation.
You may also have a look at the README.md file found in modules/cfmigrations.

Connect to your database instance and verify that a `cfmigrations` table was created.

#### B6.2 - Build schema migrations

Our schema will be created with cfmigrations CFML components. Here are the few available commands that can be run from the commandbox prompt in order to manage our application's schema.

> - migrate create <create_table_name>  // Generates an empty cfc file
> - migrate up // Commit all migration files (found in resources/database/migrations) to the db schema
> - migrate up [--once] // Commit a single migration file to the database schema
> - migrate down // Rollback all previously ran migrations that were committed to the database schema
> - migrate down [--once] // Rollback only a single migration file to the database schema
> - migrate refresh // Rollback all previous migrations down and commit all migrations up again
> - migrate reset // Clears out all objects from the database, including the cfmigrations table (use this when your database is in an inconsistent state).
> - migrate fresh // Runs migrate reset, migrate install, and migrate up to get a fresh copy of your migrated database.
> - migrate uninstall // Removes the cfmigrations table after running down any run migrations. 

##### B6.2.1 - Create empty migration files

You should refer to the ERD diagram provided with the documentation to understand how those tables are structured. We are going to create four tables in a specific order, starting with parent tables followed by child tables:

- tab_currency
- tab_country
- tab_city
- tab_airport

Let's create empty migration files with the following commands at the commandbox prompt:

> - migrate create create_tab_currency
> - migrate create create_tab_country
> - migrate create create_tab_city
> - migrate create create_tab_airport

##### B6.2.2 - Migrate the tab_currency with seed data

Order matters when running migrations. A sequence is implemented with a timestamp that is part of the migration file name that was generated when we created the empty migration files above. 

Edit the first component in resources/database/migrations named yyyy_nnnnnn_create_tab_currency.cfc.
When migrated, this component will create a table called `tab_currency`. 
Now, refer to the ERD diagram to define the columns of that table in our component:

>This table is using a 3 character code string as a primary key and another unique column. We are also going to run a bulk insert query to seed this table >with some data.

It should be defined like this:

```sh

component {

	function up( schema, qb ) {
        schema.create( "tab_currency", function(table) {
            table.string( "cur_currency_cd", 3 );
            table.primaryKey( "cur_currency_cd", "pk_tab_currency" );
            table.string("cur_currency_nm", 50).unique();
        } );

       // Bulk inserts
        qb.from( "tab_currency" )
        .insert([ { 
            "cur_currency_cd" = "EUR",
            "cur_currency_nm" = "EURO"
            },
            { 
            "cur_currency_cd" = "USD",
            "cur_currency_nm" = "US DOLLAR"
            },
            { 
            "cur_currency_cd" = "SGD",
            "cur_currency_nm" = "SINGAPORE DOLLAR"
            },
            { 
            "cur_currency_cd" = "THB",
            "cur_currency_nm" = "THAI BAHT"
            },
            { 
            "cur_currency_cd" = "AUD",
            "cur_currency_nm" = "AUSTRALIAN DOLLAR"
            },
            { 
            "cur_currency_cd" = "CAD",
            "cur_currency_nm" = "CANADIAN DOLLAR"
            }              
        ]);

      
    }

	function down( schema, qb ){
		schema.dropIfExists( "tab_currency" );

	}

}

```
Save the migration file. At the commandbox prompt, run the command: `migrate up`

This will add a new table called "tab_currency" in the database, populated with the seed data. This step by step approach, one migration component at a time, is recommended while building the schema.

##### B6.2.3 - Migrate the tab_country with seed data

Following our first migration's success, let's revert back to the original state of the database schema with no tables left other than the `cfmigrations` table. For this, run the `migrate down` command.

NB: We need to `migrate down` otherwise an error (table already exist) will be raised if we run `migrate up` without first rolling back all the tables already committed to the database schema.

Edit the second component resources/database/migrations/yyyy_nnnnnn_create_tab_country.cfc.
Refer to the ERD diagram to define the columns of that table in our empty component:

>This table has a foreign key that implements a referential integrity constraint to tab_currency. At that stage we shall only create the column >cnt_currency_cd. All referential integrity constraints will be implemented with ALTER statements in a single component, that will be created last, once all >our tables have been defined and committed successfully.

It should be defined like this:

```sh

    function up( schema, qb ) {
        schema.create( "tab_country", function(table) {
            table.string( "cnt_country_cd", 2 );
            table.primaryKey( "cnt_country_cd", "pk_tab_country" );
            table.string("cnt_currency_cd", 3);
            table.index("cnt_currency_cd", "idx_currency_cd");
            table.string("cnt_country_nm", 50);
        } );

        // Bulk inserts
        qb.from( "tab_country" )
        .insert([ { 
            "cnt_country_cd" = "US",
            "cnt_country_nm" = "UNITED STATES (USA)",
            "cnt_currency_cd" = "USD"
            },
            {
            "cnt_country_cd" = "FR",
            "cnt_country_nm" = "FRANCE",
            "cnt_currency_cd" = "EUR"
            },
            {
            "cnt_country_cd" = "IT",
            "cnt_country_nm" = "ITALY",
            "cnt_currency_cd" = "EUR"
            },
            {
            "cnt_country_cd" = "DE",
            "cnt_country_nm" = "GERMANY",
            "cnt_currency_cd" = "EUR"
            },
            {
            "cnt_country_cd" = "ES",
            "cnt_country_nm" = "SPAIN",
            "cnt_currency_cd" = "EUR"
            },
            {
            "cnt_country_cd" = "AU",
            "cnt_country_nm" = "AUSTRALIA",
            "cnt_currency_cd" = "AUD"
            },
            {
            "cnt_country_cd" = "CA",
            "cnt_country_nm" = "CANADA",
            "cnt_currency_cd" = "CAD"
            },
            {
            "cnt_country_cd" = "SG",
            "cnt_country_nm" = "SINGAPORE",
            "cnt_currency_cd" = "SGD"
            },
            {
            "cnt_country_cd" = "TH",
            "cnt_country_nm" = "THAILAND",
            "cnt_currency_cd" = "THB"
            }
        ]);

    }

    function down( schema, qb ) {
        schema.dropIfExists( "tab_country" );
    }

}

```

Save the migration file. At the commandbox prompt, run the command: `migrate up`

This will now add a new table called "tab_country" in the database, populated with seed data.


##### B6.2.4 - Migrate the tab_city with seed data

Following the last migration's success, let's revert back to the original state of the database schema once again, with no tables left other than the `cfmigrations` table. For this, run the `migrate down` command.

Edit the third component: resources/database/migrations/yyyy_nnnnnn_create_tab_city.cfc.
Refer to the ERD diagram to define the columns of that table in our empty component:

>This table has an incremental ID primary key. It also has one foreign key that implements a referential integrity constraint to tab_country.

It should be defined like this:

```sh

    function up( schema, qb ) {
        schema.create( "tab_city", function(table) {
            table.increments( "cty_city_id" );
            table.string("cty_city_nm", 50);
            table.string("cty_city_cd", 3).nullable();
            table.string( "cty_country_cd", 2 );
            table.unique([ "cty_city_nm","cty_country_cd" ], "idx_citycountry");
            table.index("cty_country_cd", "idx_country_cd");
        } );

        // Bulk inserts
        qb.from( "tab_city" )
        .insert([ { 
            "cty_city_nm" = "NEW YORK",
            "cty_city_cd" = "NYC",
            "cty_country_cd" = "US"
            },
            {
            "cty_city_nm" = "PARIS",
            "cty_city_cd" = "PAR",
            "cty_country_cd" = "FR"
            },
            {
            "cty_city_nm" = "ROME",
            "cty_city_cd" = "",
            "cty_country_cd" = "IT"
            },
            {
            "cty_city_nm" = "FRANKFURT",
            "cty_city_cd" = "",
            "cty_country_cd" = "DE"
            },
            {
            "cty_city_nm" = "BARCELONA",
            "cty_city_cd" = "",
            "cty_country_cd" = "ES"
            },
            {
            "cty_city_nm" = "MELBOURNE",
            "cty_city_cd" = "",
            "cty_country_cd" = "AU"
            },
            {
            "cty_city_nm" = "SYDNEY",
            "cty_city_cd" = "",
            "cty_country_cd" = "AU"
            },
            {
            "cty_city_nm" = "BANGKOK",
            "cty_city_cd" = "",
            "cty_country_cd" = "TH"
            },
            {
            "cty_city_nm" = "SINGAPORE",
            "cty_city_cd" = "",
            "cty_country_cd" = "SG"
            },
            {
            "cty_city_nm" = "MONTREAL",
            "cty_city_cd" = "",
            "cty_country_cd" = "CA"
            }
        ]);

    }

    function down( schema, qb ) {
        schema.dropIfExists( "tab_city" );
    }

}

```

Save the migration file. At the commandbox prompt, run the command: `migrate up`

This will now add a new table called "tab_city" in the database, populated with seed data.

##### B6.2.5 - Migrate the tab_airport with seed data

As usual, let's run the `migrate down` command to re-start with a fresh schema. 

Edit the last component resources/database/migrations/yyyy_nnnnnn_create_tab_airport.cfc. 
Refer to the ERD diagram to define the columns of that table in our empty component:

>This table is using a 3 character code string as a primary key. It also has 2 foreign keys that implement a referential integrity constraint to tab_city and tab_country.

It should be defined like this:

```sh

    function up( schema, qb ) {
        schema.create( "tab_airport", function(table) {
            table.string( "gtw_airport_cd", 3 );
            table.primaryKey( "gtw_airport_cd", "pk_tab_airport" );
            table.string("gtw_airport_nm", 50);
            table.unsignedInteger("gtw_city_id");
            table.index("gtw_city_id", "idx_city_id");
        } ); 

        // Bulk inserts
        qb.from( "tab_airport" )
        .insert([ { 
            "gtw_airport_cd" = "EWR",
            "gtw_airport_nm" = "NY NEWARK AIRPORT",
            "gtw_city_id" = 1
            },
            {
            "gtw_airport_cd" = "JFK",
            "gtw_airport_nm" = "NY KENNEDY AIRPORT",
            "gtw_city_id" = 1
            },
            {
            "gtw_airport_cd" = "CDG",
            "gtw_airport_nm" = "PARIS CHARLES DE GAULLE AIRPORT",
            "gtw_city_id" = 2
            },
            {
            "gtw_airport_cd" = "FCO",
            "gtw_airport_nm" = "ROME FIUMICINO AIRPORT",
            "gtw_city_id" = 3
            },
            {
            "gtw_airport_cd" = "FRA",
            "gtw_airport_nm" = "FRANKFURT AIRPORT",
            "gtw_city_id" = 4
            },
            {
            "gtw_airport_cd" = "BCN",
            "gtw_airport_nm" = "BARCELONA AIRPORT",
            "gtw_city_id" = 5
            },
            {
            "gtw_airport_cd" = "MEL",
            "gtw_airport_nm" = "MELBOURNE AIRPORT",
            "gtw_city_id" = 6
            },
            {
            "gtw_airport_cd" = "SYD",
            "gtw_airport_nm" = "SYDNEY AIRPORT",
            "gtw_city_id" = 7
            },
            {
            "gtw_airport_cd" = "BKK",
            "gtw_airport_nm" = "BANGKOK SUVARNABHUMI AIRPORT",
            "gtw_city_id" = 8
            },
            {
            "gtw_airport_cd" = "SIN",
            "gtw_airport_nm" = "SINGAPORE CHANGI AIRPORT",
            "gtw_city_id" = 9
            },
            {
            "gtw_airport_cd" = "YUL",
            "gtw_airport_nm" = "MONTREAL E.TRUDEAU AIRPORT",
            "gtw_city_id" = 10
            }
        ]);

    }

    function down( schema, qb ) {
        schema.dropIfExists( "tab_airport" );
    }

}

```

Save the migration file. At the commandbox prompt, run the command: `migrate up`

This will add a new table called "tab_airport" in the database. We have now created all our tables. Let's implement the referential integrity constraints associated with the foreign key relationships.

##### B6.2.6 - Migrate the foreign key relationship constraints

Now, let's run the `migrate down` command to get back to a fresh initial schema, once again, as the recommended incremental approach.

Create a new migration component called "create_fk_constraints" with the following command:
`migrate create create_fk_constraints`

```sh

    function up( schema, qb ) {

        schema.alter( "tab_country", function( table ) {
        table.addConstraint( table.foreignKey( "cnt_currency_cd" )
                             .references("cur_currency_cd")
                             .onTable("tab_currency")
                             .onDelete("RESTRICT") );
        } );

        schema.alter( "tab_city", function( table ) {
        table.addConstraint( table.foreignKey( "cty_country_cd" )
                             .references("cnt_country_cd")
                             .onTable("tab_country")
                             .onDelete("RESTRICT") );
        } );

        schema.alter( "tab_airport", function( table ) {
        table.addConstraint( table.foreignKey( "gtw_city_id" )
                             .references("cty_city_id")
                             .onTable("tab_city")
                             .onDelete("RESTRICT") );                                        
        } );

        
    }

    function down( schema, qb ) {

        // Always delete the child table before the parent table
        
        schema.drop( "tab_airport" );
        schema.drop( "tab_city" );
        schema.drop( "tab_country" );
        schema.drop( "tab_currency" );
    }

```

Save the migration file. At the commandbox prompt, run the command: `migrate up`

This will add all required foreign key constraints on "tab_country", "tab_city" and "tab_airport" in the database and complete the schema. 

### B7 - Review the installation

Go to the `cbox3` folder and have a look at its content. It should now include:

```sh

coldbox                         // Coldbox framework installation
config                          // application config directory
handlers                        // Default handlers installed with the REST template
models                          // Basic user model installed with the REST template
modules_app                     // An empty folder
resources/apidocs               // Default API docs installed with the REST template
resources/database/migrations   // The cfmigrations components folder
resources/guide                 // The project documentation
testbox                         // The TESTBOX module
tests                           // The application tests directory
.cfconfig.json
.cfformat.json
.cflintrc
.editorconfig
.env                            // The dot environment file (see paragraph B-4))   
.gitignore                      // Git version control and file tracking
.gitattributes  
Application.cfc                 // The Application.cfc file (see paragraph B-3)
box.json                        // Coldbox modules dependencies		
index.cfm
README.md
robots.txt
server.json                     // CFML server engine startup configuration

```

#### B7.1 - Run TESTBOX sample tests

Open `http://localhost:<yourportnumber>/tests` in your browser

The Colbox API REST template installation comes with integration and unit tests in the `tests/specs` folder:

> integration/AuthTests.cfc
> integration/EchoTests.cfc
> unit/UserServiceTest.cfc
> unit/Usertest.cfc

The above tests must pass when you run them.
