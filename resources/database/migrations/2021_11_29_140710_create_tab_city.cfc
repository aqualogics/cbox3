component {
    
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
