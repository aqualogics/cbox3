component {
    
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
