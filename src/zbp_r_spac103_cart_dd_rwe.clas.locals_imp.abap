CLASS lhc_Cart DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS setInitialValues FOR DETERMINE ON MODIFY
       keys FOR Cart~setInitialValues.
    METHODS AddProduct FOR MODIFY
      keys FOR ACTION Cart~AddProduct RESULT result.

ENDCLASS.

CLASS lhc_Cart IMPLEMENTATION.

  METHOD setInitialValues.

    READ ENTITIES OF zr_spac103_cart_dd_rwe IN LOCAL MODE
      ENTITY Cart
        FIELDS ( CurrencyCode CartStatus )
        WITH CORRESPONDING #( keys )
      RESULT DATA(carts).

    MODIFY ENTITIES OF zr_spac103_cart_dd_rwe IN LOCAL MODE
      ENTITY Cart
        UPDATE FIELDS ( CurrencyCode CartStatus )
        WITH VALUE #(
          FOR cart IN carts
          (
            %tky = cart-%tky

            CurrencyCode = COND #(
              WHEN cart-CurrencyCode IS INITIAL
              THEN 'DKK'
              ELSE cart-CurrencyCode
            )

            CartStatus = COND #(
              WHEN cart-CartStatus IS INITIAL
              THEN 'O'
              ELSE cart-CartStatus
            )
          )
        ).

  ENDMETHOD.

  METHOD AddProduct.

    " Read the shopping carts
    READ ENTITIES OF zr_spac103_cart_dd_rwe IN LOCAL MODE
      ENTITY Cart
        FIELDS ( CurrencyCode CartStatus )
        WITH CORRESPONDING #( keys )
      RESULT DATA(carts).

    DATA cid_counter TYPE i VALUE 0.
    LOOP AT keys INTO DATA(key).

      " Find the corresponding cart
      READ TABLE carts INTO DATA(cart)
        WITH TABLE KEY id COMPONENTS %tky = key-%tky.

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      " Only open carts can be modified
      IF cart-CartStatus <> 'O'.

        APPEND VALUE #(
          %tky = key-%tky
          %fail-cause = if_abap_behv=>cause-unspecific
        ) TO failed-cart.

        APPEND VALUE #(
          %tky = key-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = 'Cannot add products to a completed cart.'
          )
          %action-AddProduct = if_abap_behv=>mk-on
        ) TO reported-cart.

        CONTINUE.
      ENDIF.

      " Validate quantity
      IF key-%param-Quantity <= 0.

        APPEND VALUE #(
          %tky = key-%tky
          %fail-cause = if_abap_behv=>cause-unspecific
        ) TO failed-cart.

        APPEND VALUE #(
          %tky = key-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = 'Quantity must be greater than zero.'
          )
          %action-AddProduct = if_abap_behv=>mk-on
        ) TO reported-cart.

        CONTINUE.
      ENDIF.

      " Validate product id
      IF key-%param-ProductId IS INITIAL.
        APPEND VALUE #(
          %tky = key-%tky
          %fail-cause = if_abap_behv=>cause-unspecific
        ) TO failed-cart.

        APPEND VALUE #(
          %tky = key-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = 'Please select a product.'
          )
          %action-AddProduct = if_abap_behv=>mk-on
        ) TO reported-cart.

        CONTINUE.

      ENDIF.

      " Check that the product exists
      SELECT SINGLE product_name
        FROM zspac103_product
        WHERE product_id = @key-%param-ProductId
        INTO @DATA(product_name).

      IF sy-subrc <> 0.

        APPEND VALUE #(
          %tky = key-%tky
          %fail-cause = if_abap_behv=>cause-unspecific
        ) TO failed-cart.

        APPEND VALUE #(
          %tky = key-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = 'The selected product does not exist.'
          )
          %action-AddProduct = if_abap_behv=>mk-on
        ) TO reported-cart.

        CONTINUE.
      ENDIF.

      " Find the product price in the cart currency
      SELECT SINGLE product_price
        FROM zspac103_p_price
        WHERE product_id = @key-%param-ProductId
          AND product_currency_code = @cart-CurrencyCode
        INTO @DATA(unit_price).

      IF sy-subrc <> 0.

        APPEND VALUE #(
          %tky = key-%tky
          %fail-cause = if_abap_behv=>cause-unspecific
        ) TO failed-cart.

        APPEND VALUE #(
          %tky = key-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = 'The selected product has no price in the cart currency.'
          )
          %action-AddProduct = if_abap_behv=>mk-on
        ) TO reported-cart.

        CONTINUE.
      ENDIF.

      " Check whether the product is already in the cart
      READ ENTITIES OF zr_spac103_cart_dd_rwe IN LOCAL MODE
        ENTITY Item
          FIELDS ( Quantity )
          WITH VALUE #(
            (
              CartUUID = key-%tky-CartUUID
              ProductId = key-%param-ProductId
              %is_draft = key-%tky-%is_draft
            )
          )
        RESULT DATA(existing_items).

      IF existing_items IS NOT INITIAL.

        " Increase the quantity of the existing item
        MODIFY ENTITIES OF zr_spac103_cart_dd_rwe IN LOCAL MODE
          ENTITY Item
            UPDATE FIELDS ( Quantity )
            WITH VALUE #(
              (
                %tky = existing_items[ 1 ]-%tky
                Quantity = existing_items[ 1 ]-Quantity
                         + key-%param-Quantity
              )
            ).

       ELSE.

        " Create a new cart item through the cart composition
        cid_counter = cid_counter + 1.

        MODIFY ENTITIES OF zr_spac103_cart_dd_rwe IN LOCAL MODE
          ENTITY Cart
            CREATE BY \_Items
            FIELDS (
              ProductId
              ProductName
              Quantity
              CurrencyCode
              UnitPrice
            )
            WITH VALUE #(
              (
                CartUUID = key-%tky-CartUUID
                %is_draft = key-%tky-%is_draft

                %target = VALUE #(
                  (
                    %cid = |NEW_ITEM_{ cid_counter }|
                    %is_draft = key-%tky-%is_draft

                    ProductId = key-%param-ProductId
                    ProductName = product_name
                    Quantity = key-%param-Quantity
                    CurrencyCode = cart-CurrencyCode
                    UnitPrice = unit_price
                  )
                )
              )
            ).

      ENDIF.

    ENDLOOP.

    " Return the updated shopping carts
    READ ENTITIES OF zr_spac103_cart_dd_rwe IN LOCAL MODE
      ENTITY Cart
        ALL FIELDS
        WITH CORRESPONDING #( keys )
      RESULT DATA(updated_carts).

    LOOP AT updated_carts INTO DATA(updated_cart).

      IF NOT line_exists( failed-cart[
        KEY id COMPONENTS %tky = updated_cart-%tky
      ] ).
        APPEND VALUE #(
          %tky = updated_cart-%tky
          %param = CORRESPONDING #( updated_cart )
        ) TO result.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
