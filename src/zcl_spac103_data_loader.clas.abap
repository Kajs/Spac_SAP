CLASS ZCL_SPAC103_DATA_LOADER DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS:
      fill_table
        RETURNING VALUE(r_output) TYPE string
        RAISING cx_sy_open_sql_db,
      cleanup
        RETURNING VALUE(r_output) TYPE STRING.

ENDCLASS.


CLASS ZCL_SPAC103_DATA_LOADER IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    out->write( cleanup(  ) ).

    TRY.
      out->write( fill_table(  ) ).
    CATCH cx_sy_open_sql_db INTO DATA(lx).
      out->write( |Couldn't write entries to table. Error: { lx->get_longtext(  ) }| ).
    ENDTRY.

  ENDMETHOD.


  METHOD fill_table.
*                                  ÆNDR TABELNAVNET
*                                  vvvvvvvvvvvvvvvv
    DATA: temp_table_stock TYPE TABLE OF  zspac103_stock .
*                                  ^^^^^^^^^^^^^^^^

    temp_table_stock = VALUE #(
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*   Ændr data herunder, når du vil fylde data på andre tabeller
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      ( warehouse_id = 1 product_id = 1 amount =   3 )
      ( warehouse_id = 3 product_id = 4 amount =  42 )
      ( warehouse_id = 2 product_id = 5 amount =   1 )
      ( warehouse_id = 3 product_id = 5 amount = 321 )
      ( warehouse_id = 3 product_id = 1 amount =  20 )
      ( warehouse_id = 1 product_id = 5 amount =   9 )
      ( warehouse_id = 2 product_id = 3 amount =   5 )
      ( warehouse_id = 3 product_id = 2 amount =   4 )
      ( warehouse_id = 1 product_id = 4 amount =   0 )
      ( warehouse_id = 3 product_id = 3 amount =   8 )
      ( warehouse_id = 1 product_id = 3 amount = 100 )
      ( warehouse_id = 1 product_id = 2 amount =   7 )
      ( warehouse_id = 2 product_id = 4 amount =   0 )
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*   Ændr data herover, når du vil fylde data på andre tabeller
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    ).

    TRY.

      INSERT  zspac103_stock  FROM TABLE @( CORRESPONDING #( temp_table_stock ) ).

    CATCH cx_sy_open_sql_db INTO DATA(exStock).
      RAISE EXCEPTION exStock.
    ENDTRY.

    DATA(stock_inserted) = sy-dbcnt.
    r_output = |Inserted { stock_inserted } entries into zspac103_stock.|.

*_____________ZSPAC103_PRODUCT____________

    DATA: temp_table_product TYPE TABLE OF  ZSPAC103_PRODUCT .

    temp_table_product = VALUE #(

      ( product_id = 1 product_name = 'Stegepande'     product_description = 'Stegepande i rustfrit stål og anti stick med indbygget gps.' )
      ( product_id = 2 product_name = 'Pincet'         product_description = 'Pincet i praktisk størrelse til dig, der er på farten. Nu med indbygget lommelygte.' )
      ( product_id = 3 product_name = 'Megapint'       product_description = 'Vinglas i ekstra stor størrelse, til dig, der vil have hele flasken i ét glas.' )
      ( product_id = 4 product_name = 'Finger Taske'   product_description = 'Ekstra lille taske, til at spænde om fingeren. Hav dine tandstikker og nåle tilgængelige til enhver tid!' )
      ( product_id = 5 product_name = 'Stempelkande'   product_description = 'Praktisk stempelkande, til den kræsne kaffedrikker. Nu med indbygget vækkeur.' )
    ).

    TRY.
      INSERT  ZSPAC103_PRODUCT  FROM TABLE @( CORRESPONDING #( temp_table_product ) ).

    CATCH cx_sy_open_sql_db INTO DATA(exProduct).
      RAISE EXCEPTION exProduct.
    ENDTRY.

    DATA(product_inserted) = sy-dbcnt.
    r_output = r_output &&
      |\nInserted { product_inserted } entries into zspac103_product.|.

*_____________ZSPAC103_P_PRICE____________

    DATA: temp_table_p_price TYPE TABLE OF  ZSPAC103_P_PRICE .

    temp_table_p_price = VALUE #(

      ( product_id = 1 product_price = '249.95'     product_currency_code = 'DKK' )
      ( product_id = 1 product_price = '33.42'      product_currency_code = 'EUR' )
      ( product_id = 2 product_price = '19.99'      product_currency_code = 'DKK' )
      ( product_id = 2 product_price = '2.68'       product_currency_code = 'EUR' )
      ( product_id = 3 product_price = '50.00'      product_currency_code = 'DKK' )
      ( product_id = 3 product_price = '6.69'       product_currency_code = 'EUR' )
      ( product_id = 4 product_price = '39.99'      product_currency_code = 'DKK' )
      ( product_id = 4 product_price = '5.35'       product_currency_code = 'EUR' )
      ( product_id = 5 product_price = '149.99'     product_currency_code = 'DKK' )
      ( product_id = 5 product_price = '20.07'      product_currency_code = 'EUR' )
    ).

    TRY.
      INSERT  ZSPAC103_P_PRICE  FROM TABLE @( CORRESPONDING #( temp_table_p_price ) ).

    CATCH cx_sy_open_sql_db INTO DATA(exPrice).
      RAISE EXCEPTION exPrice.
    ENDTRY.

    DATA(price_inserted) = sy-dbcnt.
    r_output = r_output &&
      |\nInserted { price_inserted } entries into zspac103_p_price.|.

*_____________ZSPAC103_WAREHOU____________

    DATA: temp_table_warehou TYPE TABLE OF  ZSPAC103_WAREHOU .

    temp_table_warehou = VALUE #(

      ( warehouse_id = 1 warehouse_address = 'Termogade 23'     warehouse_zipcode = 6700 warehouse_city = 'Esbjerg' warehouse_name = 'Isenkrammeren' )
      ( warehouse_id = 2 warehouse_address = 'Tykstegsgade 230' warehouse_zipcode = 5000 warehouse_city = 'Odense'  warehouse_name = 'Isenkrammeren' )
      ( warehouse_id = 3 warehouse_address = 'Kirkestræde 12'   warehouse_zipcode = 5960 warehouse_city = 'Marstal' warehouse_name = 'Isenkrammeren' )
    ).

    TRY.
      INSERT  ZSPAC103_WAREHOU  FROM TABLE @( CORRESPONDING #( temp_table_warehou ) ).

    CATCH cx_sy_open_sql_db INTO DATA(exWarehou).
      RAISE EXCEPTION exWarehou.
    ENDTRY.

    DATA(warehou_inserted) = sy-dbcnt.
    r_output = r_output &&
      |\nInserted { warehou_inserted } entries into zspac103_warehou.|.

  ENDMETHOD.

  METHOD cleanup.

    DELETE FROM zspac103_stock.
    DATA(stock_deleted) = sy-dbcnt.

    DELETE FROM zspac103_product.
    DATA(product_deleted) = sy-dbcnt.

    DELETE FROM zspac103_p_price.
    DATA(price_deleted) = sy-dbcnt.

    DELETE FROM zspac103_warehou.
    DATA(warehou_deleted) = sy-dbcnt.


    COMMIT WORK.

    r_output =
      |Successfully cleaned up { stock_deleted } entries from zspac103_stock.| &&
      |\nSuccessfully cleaned up { product_deleted } entries from zspac103_product.| &&
      |\nSuccessfully cleaned up { price_deleted } entries from zspac103_p_price.| &&
      |\nSuccessfully cleaned up { warehou_deleted } entries from zspac103_warehou.|.

  ENDMETHOD.
ENDCLASS.
