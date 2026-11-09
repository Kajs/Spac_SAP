CLASS zcl_spac103_rap_tester DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.

ENDCLASS.



CLASS zcl_spac103_rap_tester IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    " 1. Clean up any previous test record
    DELETE FROM zspac103_stock
      WHERE warehouse_id = 99
        AND product_id = 99.

    out->write( |Cleanup: removed { sy-dbcnt } previous test record(s).| ).

    COMMIT WORK.

    " 2. Create a new record with a valid amount
    MODIFY ENTITIES OF zr_spac103_stock_dd_rwe
      ENTITY zr_spac103_stock_dd_rwe
        CREATE FIELDS ( WarehouseId ProductId Amount )
        WITH VALUE #(
          ( %cid = 'TEST1'
            WarehouseId = 99
            ProductId = 99
            Amount = 5 )
        )
      FAILED DATA(create_failed)
      REPORTED DATA(create_reported).

    COMMIT ENTITIES RESPONSE OF zr_spac103_stock_dd_rwe
      FAILED DATA(create_commit_failed)
      REPORTED DATA(create_commit_reported).

    IF create_failed-zr_spac103_stock_dd_rwe IS INITIAL
       AND create_commit_failed-zr_spac103_stock_dd_rwe IS INITIAL.
      out->write( |Create: successful (amount = 5).| ).
    ELSE.
      out->write( |Create: FAILED.| ).
      out->write( create_failed ).
      out->write( create_commit_failed ).
      out->write( create_commit_reported ).
      RETURN.
    ENDIF.

    " 3. Update the record to another valid amount
    MODIFY ENTITIES OF zr_spac103_stock_dd_rwe
      ENTITY zr_spac103_stock_dd_rwe
        UPDATE FIELDS ( Amount )
        WITH VALUE #(
          ( WarehouseId = 99
            ProductId = 99
            Amount = 10 )
        )
      FAILED DATA(update_failed)
      REPORTED DATA(update_reported).

    COMMIT ENTITIES RESPONSE OF zr_spac103_stock_dd_rwe
      FAILED DATA(update_commit_failed)
      REPORTED DATA(update_commit_reported).

    IF update_failed-zr_spac103_stock_dd_rwe IS INITIAL
       AND update_commit_failed-zr_spac103_stock_dd_rwe IS INITIAL.
      out->write( |Valid update: successful (amount = 10).| ).
    ELSE.
      out->write( |Valid update: FAILED.| ).
      out->write( update_failed ).
      out->write( update_commit_failed ).
      out->write( update_commit_reported ).
      RETURN.
    ENDIF.

    " 4. Attempt an invalid update
    MODIFY ENTITIES OF zr_spac103_stock_dd_rwe
      ENTITY zr_spac103_stock_dd_rwe
        UPDATE FIELDS ( Amount )
        WITH VALUE #(
          ( WarehouseId = 99
            ProductId = 99
            Amount = -1 )
        )
      FAILED DATA(invalid_update_failed)
      REPORTED DATA(invalid_update_reported).

    COMMIT ENTITIES RESPONSE OF zr_spac103_stock_dd_rwe
      FAILED DATA(invalid_commit_failed)
      REPORTED DATA(invalid_commit_reported).

    IF invalid_commit_failed-zr_spac103_stock_dd_rwe IS NOT INITIAL.
      out->write( |Invalid update: correctly rejected.| ).
      out->write( invalid_commit_reported ).
    ELSE.
      out->write( |Invalid update: UNEXPECTEDLY SUCCEEDED!| ).
    ENDIF.

    " 5. Check what is actually stored in the database
    SELECT SINGLE amount
      FROM zspac103_stock
      WHERE warehouse_id = 99
        AND product_id = 99
      INTO @DATA(stored_amount).

    IF sy-subrc = 0.
      out->write( |Final database amount: { stored_amount }.| ).
    ELSE.
      out->write( |Final database check: record not found!| ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
