component {
    
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

}
