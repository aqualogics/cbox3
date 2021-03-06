component {
    
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
