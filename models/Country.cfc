component accessors="true" {

	// properties

    property name="countryCD";
    property name="countryName";
	property name="countryCurrencyCD";

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
		countryCD    : { required : true },
		countryName  : { required : true },
		countryCurrencyCD  : { required : true }
	};

	/**
	* Constructor
	*/

	Country function init(string countryCD,
						  string countryName,
						  string countryCurrencyCD) {
		
		variables.countryCD = arguments.countryCD;
		variables.countryName = arguments.countryName;
		variables.countryCurrencyCD = arguments.countryCurrencyCD;

		return this;
	}

    /**
	 * Check if a Country entity object is loaded
	 */
    
	boolean function isLoaded() {
		return ( !isNull( variables.countryCD ) && len( variables.countryCD ) );
	}

}	