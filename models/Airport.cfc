component accessors="true" {

	// properties

    property name="airportCD";
    property name="airportName";
	property name="airportCityID";

	/**
	 * --------------------------------------------------------------------------
	 * Mementifier
	 * --------------------------------------------------------------------------
	 */
	this.memento = {
		defaultIncludes : [ "*" ],
		defaultExcludes : [],
		neverInclude    : []
	};

	/**
	 * --------------------------------------------------------------------------
	 * Validation
	 * --------------------------------------------------------------------------
	 */
	this.constraints = {
		airportCD    : { required : true },
		airportName  : { required : true },
		airportCityID  : { required : true }
	};

	/**
	* Constructor
	*/

	Airport function init(string airportCD,
						  string airportName,
						  numeric airportCityID) {
		
		variables.airportCD = arguments.airportCD;
		variables.airportName = arguments.airportName;
		variables.airportCityID = arguments.airportCityID;

		return this;
	}

    /**
	 * Check if an Airport entity object is loaded
	 */
    
	boolean function isLoaded() {
		return ( !isNull( variables.airportCD ) && len( variables.airportCD ) );
	}

}	