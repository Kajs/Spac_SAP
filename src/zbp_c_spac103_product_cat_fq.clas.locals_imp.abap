CLASS lhc_Product DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS read FOR READ
       keys FOR READ Product RESULT result.

    METHODS lock FOR LOCK
       keys FOR LOCK Product.

    METHODS AddToCart FOR MODIFY
       keys FOR ACTION Product~AddToCart.

ENDCLASS.

CLASS lhc_Product IMPLEMENTATION.

  METHOD read.

    LOOP AT keys INTO DATA(key).

      " Read the requested product and currency combination
      SELECT SINGLE FROM ZC_SPAC103_PRODUCT_CAT_FQ
        FIELDS ProductName,
               ProductDescription,
               ProductImage,
               ImageMimeType,
               ImageFileName,
               ProductPrice,
               ProductPriceNullIndicator
        WHERE ProductId = @key-ProductId
          AND ProductCurrencyCode = @key-ProductCurrencyCode
        INTO @DATA(product).

      IF sy-subrc = 0.

        " Return the product to RAP
        APPEND VALUE #(
          %tky = key-%tky
          ProductName = product-ProductName
          ProductDescription = product-ProductDescription
          ProductImage = product-ProductImage
          ImageMimeType = product-ImageMimeType
          ImageFileName = product-ImageFileName
          ProductPrice = product-ProductPrice
          ProductPriceNullIndicator = product-ProductPriceNullIndicator
        ) TO result.

      ELSE.

        " Product and currency combination was not found
        APPEND VALUE #(
          %tky = key-%tky
          %fail-cause = if_abap_behv=>cause-not_found
        ) TO failed-product.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD AddToCart.

    DATA cart_uuid TYPE zspac103_cart-cart_uuid.
    DATA new_cart_counter TYPE i VALUE 0.

    LOOP AT keys INTO DATA(key).

      " Validate quantity before creating a cart
      IF key-%param-Quantity <= 0.

        APPEND VALUE #(
          %tky = key-%tky
          %fail-cause = if_abap_behv=>cause-unspecific
        ) TO failed-product.

        APPEND VALUE #(
          %tky = key-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = 'Quantity must be greater than zero.'
          )
          %action-AddToCart = if_abap_behv=>mk-on
        ) TO reported-product.

        CONTINUE.
      ENDIF.

      " Check that a price exists in the selected currency
      SELECT SINGLE product_id
        FROM zspac103_p_price
        WHERE product_id = @key-ProductId
          AND product_currency_code = @key-ProductCurrencyCode
        INTO @DATA(priced_product_id).

      IF sy-subrc <> 0.

        APPEND VALUE #(
          %tky = key-%tky
          %fail-cause = if_abap_behv=>cause-unspecific
        ) TO failed-product.

        APPEND VALUE #(
          %tky = key-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = 'The selected product has no price in the selected currency.'
          )
          %action-AddToCart = if_abap_behv=>mk-on
        ) TO reported-product.

        CONTINUE.
      ENDIF.

      " Find open carts belonging to the current user and currency
      SELECT cart_uuid
        FROM zspac103_cart
        WHERE local_created_by = @sy-uname
          AND currency_code = @key-ProductCurrencyCode
          AND cart_status = 'O'
        INTO TABLE @DATA(open_carts).

      " Do not choose arbitrarily if multiple matching carts exist
      IF lines( open_carts ) > 1.

        APPEND VALUE #(
          %tky = key-%tky
          %fail-cause = if_abap_behv=>cause-unspecific
        ) TO failed-product.

        APPEND VALUE #(
          %tky = key-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = 'Multiple open carts exist for your user and selected currency.'
          )
          %action-AddToCart = if_abap_behv=>mk-on
        ) TO reported-product.

        CONTINUE.
      ENDIF.

      CLEAR cart_uuid.

      IF open_carts IS INITIAL.

        " No matching cart exists - create a new active cart
        new_cart_counter = new_cart_counter + 1.

        MODIFY ENTITIES OF zr_spac103_cart_dd_rwe
          ENTITY Cart
            CREATE FIELDS ( CurrencyCode )
            WITH VALUE #(
              (
                %cid = |NEW_CART_{ new_cart_counter }|
                %is_draft = if_abap_behv=>mk-off
                CurrencyCode = key-ProductCurrencyCode
              )
            )
          MAPPED DATA(mapped_create)
          FAILED DATA(failed_create)
          REPORTED DATA(reported_create).

        IF failed_create-cart IS NOT INITIAL
           OR mapped_create-cart IS INITIAL.

          APPEND VALUE #(
            %tky = key-%tky
            %fail-cause = if_abap_behv=>cause-unspecific
          ) TO failed-product.

          IF reported_create-cart IS NOT INITIAL.

            LOOP AT reported_create-cart INTO DATA(create_message).

              APPEND VALUE #(
                %tky = key-%tky
                %msg = create_message-%msg
                %action-AddToCart = if_abap_behv=>mk-on
              ) TO reported-product.

            ENDLOOP.

          ELSE.

            APPEND VALUE #(
              %tky = key-%tky
              %msg = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text = 'Could not create a shopping cart.'
              )
              %action-AddToCart = if_abap_behv=>mk-on
            ) TO reported-product.

          ENDIF.

          CONTINUE.
        ENDIF.

        " Get the UUID of the newly created cart
        cart_uuid = mapped_create-cart[ 1 ]-%tky-CartUUID.

      ELSE.

        " Reuse the existing open cart
        cart_uuid = open_carts[ 1 ]-cart_uuid.

      ENDIF.

      " Delegate the actual product insertion to Cart.AddProduct
      MODIFY ENTITIES OF zr_spac103_cart_dd_rwe
        ENTITY Cart
          EXECUTE AddProduct FROM VALUE #(
            (
              CartUUID = cart_uuid
              %is_draft = if_abap_behv=>mk-off
              %param = VALUE #(
                ProductId = key-ProductId
                Quantity = key-%param-Quantity
              )
            )
          )
        FAILED DATA(failed_add)
        REPORTED DATA(reported_add).

      " Forward any errors from the existing Cart action
      IF failed_add-cart IS NOT INITIAL.

        APPEND VALUE #(
          %tky = key-%tky
          %fail-cause = if_abap_behv=>cause-unspecific
        ) TO failed-product.

        IF reported_add-cart IS NOT INITIAL.

          LOOP AT reported_add-cart INTO DATA(add_message).

            APPEND VALUE #(
              %tky = key-%tky
              %msg = add_message-%msg
              %action-AddToCart = if_abap_behv=>mk-on
            ) TO reported-product.

          ENDLOOP.

        ELSE.

          APPEND VALUE #(
            %tky = key-%tky
            %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text = 'Could not add the product to the shopping cart.'
            )
            %action-AddToCart = if_abap_behv=>mk-on
          ) TO reported-product.

        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZC_SPAC103_PRODUCT_CAT_FQ DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZC_SPAC103_PRODUCT_CAT_FQ IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
