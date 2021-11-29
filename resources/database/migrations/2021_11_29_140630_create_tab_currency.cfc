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

    function down( schema, qb ) {
        schema.dropIfExists( "tab_currency" );
    }

}
