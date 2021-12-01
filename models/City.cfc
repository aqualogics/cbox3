component accessors="true" {

	// properties

    property name="cityID";
    property name="cityName";
	property name="cityCD";
	property name="cityCountryCD";

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
		cityName  	   : { required : true },
		cityCD    	   : { required : false },
		cityCountryCD  : { required : true }
	};

	/**
	* Constructor
	*/

	City function init(cityID,
					   cityName,
					   cityCD,
					   cityCountryCD) {
		
		variables.cityID = arguments.cityID;
		variables.cityName = arguments.cityName;
		variables.cityCD = arguments.cityCD;
		variables.cityCountryCD = arguments.cityCountryCD;

		return this;

	}

    /**
	 * Check if a City entity object is loaded
	 */
    
	boolean function isLoaded() {
		return ( !isNull( variables.cityID ) && len( variables.cityID ) );
	}

}	