component accessors="true" {

	// properties

    property name="currencyCD";
    property name="currencyName";

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
		currencyCD    : { required : true },
		currencyName  : { required : true }
	};

	/**
	* Constructor
	*/

	Currency function init(string currencyCD,
						   string currencyName) {
		
		variables.currencyCD = arguments.currencyCD;
		variables.currencyName = arguments.currencyName;

		return this;
	}

    /**
	 * Check if a Currency entity object is loaded
	 */
    
	boolean function isLoaded() {
		return ( !isNull( variables.currencyCD ) && len( variables.currencyCD ) );
	}

}	