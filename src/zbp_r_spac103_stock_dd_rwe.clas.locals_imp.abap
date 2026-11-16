CLASS lhc_ZR_SPAC103_STOCK_DD_RWE DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR zr_spac103_stock_dd_rwe RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR zr_spac103_stock_dd_rwe RESULT result.

    METHODS validateAmount FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_spac103_stock_dd_rwe~validateAmount.

    METHODS validateReferences FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_spac103_stock_dd_rwe~validateReferences.

ENDCLASS.

CLASS lhc_ZR_SPAC103_STOCK_DD_RWE IMPLEMENTATION.

  METHOD get_instance_authorizations.

    LOOP AT keys INTO DATA(key).

      APPEND VALUE #(
        %tky = key-%tky
        %update = if_abap_behv=>auth-allowed
        %delete = if_abap_behv=>auth-allowed
      ) TO result.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_global_authorizations.

    IF requested_authorizations-%create = if_abap_behv=>mk-on.
      result-%create = if_abap_behv=>auth-allowed.
    ENDIF.

  ENDMETHOD.

  METHOD validateAmount.
    READ ENTITIES OF zr_spac103_stock_dd_rwe IN LOCAL MODE
      ENTITY zr_spac103_stock_dd_rwe
        FIELDS ( Amount )
        WITH CORRESPONDING #( keys )
      RESULT DATA(stock_records).

    LOOP AT stock_records INTO DATA(stock_record).

      IF stock_record-Amount < 0.

        APPEND VALUE #(
          %tky = stock_record-%tky
        ) TO failed-zr_spac103_stock_dd_rwe.

        APPEND VALUE #(
          %tky = stock_record-%tky
          %element-Amount = if_abap_behv=>mk-on
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = 'Stock amount cannot be negative'
          )
        ) TO reported-zr_spac103_stock_dd_rwe.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateReferences.

    READ ENTITIES OF zr_spac103_stock_dd_rwe IN LOCAL MODE
      ENTITY zr_spac103_stock_dd_rwe
        FIELDS ( WarehouseId ProductId )
        WITH CORRESPONDING #( keys )
      RESULT DATA(stock_records).

    DATA invalid_reference TYPE abap_bool.

    LOOP AT stock_records INTO DATA(stock_record).

      CLEAR invalid_reference.

      " Clear previous messages from this validation
      APPEND VALUE #(
        %tky = stock_record-%tky
        %state_area = 'VALIDATE_REFERENCES'
      ) TO reported-zr_spac103_stock_dd_rwe.

      " Check if the product exists
      SELECT SINGLE @abap_true
        FROM zspac103_product
        WHERE product_id = @stock_record-ProductId
        INTO @DATA(product_exists).

      IF sy-subrc <> 0.

        invalid_reference = abap_true.

        APPEND VALUE #(
          %tky = stock_record-%tky
          %state_area = 'VALIDATE_REFERENCES'
          %element-ProductId = if_abap_behv=>mk-on
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = |Product ID { stock_record-ProductId } does not exist.|
          )
        ) TO reported-zr_spac103_stock_dd_rwe.

      ENDIF.

      " Check if the warehouse exists
      SELECT SINGLE @abap_true
        FROM zspac103_warehou
        WHERE warehouse_id = @stock_record-WarehouseId
        INTO @DATA(warehouse_exists).

      IF sy-subrc <> 0.

        invalid_reference = abap_true.

        APPEND VALUE #(
          %tky = stock_record-%tky
          %state_area = 'VALIDATE_REFERENCES'
          %element-WarehouseId = if_abap_behv=>mk-on
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = |Warehouse ID { stock_record-WarehouseId } does not exist.|
          )
        ) TO reported-zr_spac103_stock_dd_rwe.

      ENDIF.

      IF invalid_reference = abap_true.
        APPEND VALUE #(
          %tky = stock_record-%tky
        ) TO failed-zr_spac103_stock_dd_rwe.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
