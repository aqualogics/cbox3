component {

	function configure() {
		// Set Full Rewrites
		setFullRewrites( true );

		/**
		 * --------------------------------------------------------------------------
		 * App Routes
		 * --------------------------------------------------------------------------
		 *
		 * Here is where you can register the routes for your web application!
		 * Go get Funky!
		 *
		 */

		// A nice healthcheck route example
		route( "/healthcheck", function( event, rc, prc ) {
			return "Ok!";
		} );

		// API Echo
		get( "/api/echo", "Echo.index" );

		// API Authentication Routes
		post( "/api/login", "Auth.login" );
		post( "/api/logout", "Auth.logout" );
		post( "/api/register", "Auth.register" );

		// API Secured Routes
		get( "/api/whoami", "Echo.whoami" );

		// Currency API routing

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

		// Country API routing

		route( "/api/country/:countryCD" )
		.withAction( {
			GET    : "show",
			PUT    : "update",
			DELETE : "delete"
		} )
		.toHandler( "CountryAPI" );

		route( "/api/country" )
		.withAction( {
			GET    : "index",
			POST   : "create"
		} )
		.toHandler( "CountryAPI" );

		// City API routing

		route( "/api/city/:cityID" )
		.withAction( {
			GET    : "show",
			PUT    : "update",
			DELETE : "delete"
		} )
		.toHandler( "CityAPI" );

		route( "/api/city" )
		.withAction( {
			GET    : "index",
			POST   : "create"
		} )
		.toHandler( "CityAPI" );

		// Airport API routing

		route( "/api/airport/:airportCD" )
		.withAction( {
			GET    : "show",
			PUT    : "update",
			DELETE : "delete"
		} )
		.toHandler( "AirportAPI" );

		route( "/api/airport" )
		.withAction( {
			GET    : "index",
			POST   : "create"
		} )
		.toHandler( "AirportAPI" );


		// Conventions based routing
		route( ":handler/:action?" ).end();
	}

}
