CLASS lhc_price DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS validatePrice FOR VALIDATE ON SAVE
      keys FOR Price~validatePrice.

ENDCLASS.

CLASS lhc_price IMPLEMENTATION.

  METHOD validatePrice.

    READ ENTITIES OF zr_spac103_product_dd_rwe IN LOCAL MODE
      ENTITY Price
        FIELDS ( ProductPrice ProductCurrencyCode )
        WITH CORRESPONDING #( keys )
      RESULT DATA(prices).

    SELECT FROM I_Currency WITH PRIVILEGED ACCESS
      FIELDS Currency
      INTO TABLE @DATA(currency_codes).

    LOOP AT prices INTO DATA(price).

      IF price-ProductPrice < 0.

        APPEND VALUE #(
          %tky = price-%tky
        ) TO failed-price.

        APPEND VALUE #(
          %tky = price-%tky
          %element-ProductPrice = if_abap_behv=>mk-on
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = 'Product price cannot be negative.'
          )
        ) TO reported-price.

      ENDIF.

      IF NOT line_exists( currency_codes[
        Currency = price-ProductCurrencyCode ] ).

        APPEND VALUE #(
          %tky = price-%tky
        ) TO failed-price.

        APPEND VALUE #(
          %tky = price-%tky
          %element-ProductCurrencyCode = if_abap_behv=>mk-on
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = |Currency { price-ProductCurrencyCode } does not exist.|
          )
        ) TO reported-price.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_ZR_SPAC103_PRODUCT_DD_RWE DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR zr_spac103_product_dd_rwe RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR zr_spac103_product_dd_rwe RESULT result.

ENDCLASS.

CLASS lhc_ZR_SPAC103_PRODUCT_DD_RWE IMPLEMENTATION.

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

ENDCLASS.
