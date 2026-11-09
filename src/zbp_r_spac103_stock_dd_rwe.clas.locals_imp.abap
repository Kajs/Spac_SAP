CLASS lhc_ZR_SPAC103_STOCK_DD_RWE DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR zr_spac103_stock_dd_rwe RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR zr_spac103_stock_dd_rwe RESULT result.

    METHODS validateAmount FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_spac103_stock_dd_rwe~validateAmount.

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

ENDCLASS.
