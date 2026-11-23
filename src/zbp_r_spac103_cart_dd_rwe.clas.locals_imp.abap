CLASS lhc_Cart DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS setInitialValues FOR DETERMINE ON MODIFY
       keys FOR Cart~setInitialValues.

    METHODS AddProduct FOR MODIFY
      keys FOR ACTION Cart~AddProduct RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR Cart RESULT result.

    METHODS Checkout FOR MODIFY
      keys FOR ACTION Cart~Checkout RESULT result.

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

  METHOD get_instance_features.

    READ ENTITIES OF zr_spac103_cart_dd_rwe IN LOCAL MODE
      ENTITY Cart
        FIELDS ( CartStatus )
        WITH CORRESPONDING #( keys )
      RESULT DATA(carts).

    LOOP AT keys INTO DATA(key).

      READ TABLE carts INTO DATA(cart)
        WITH TABLE KEY id COMPONENTS %tky = key-%tky.

      IF sy-subrc = 0.

        APPEND VALUE #(
          %tky = key-%tky
          %features-%action-Checkout = COND #(
            WHEN cart-CartStatus = 'O'
             AND key-%tky-%is_draft = if_abap_behv=>mk-off
            THEN if_abap_behv=>fc-o-enabled
            ELSE if_abap_behv=>fc-o-disabled
          )
        ) TO result.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD Checkout.

    TYPES:
      BEGIN OF ty_allocation,
        ProductId         TYPE i,
        WarehouseId       TYPE i,
        AllocatedQuantity TYPE i,
      END OF ty_allocation.

    TYPES:
      BEGIN OF ty_shortage,
        ProductId TYPE i,
        Requested TYPE i,
        Available TYPE i,
      END OF ty_shortage.

    DATA shortages TYPE STANDARD TABLE OF ty_shortage
      WITH EMPTY KEY.
    DATA stock_lock_keys TYPE TABLE FOR KEY OF zr_spac103_stock_dd_rwe.
    DATA stock_updates   TYPE TABLE FOR UPDATE zr_spac103_stock_dd_rwe.

    DATA allocation_cba TYPE TABLE FOR CREATE
      zr_spac103_cart_dd_rwe\\Item\_Allocations.

    DATA allocation_plan TYPE STANDARD TABLE OF ty_allocation
      WITH EMPTY KEY.

    DATA remaining_quantity  TYPE i.
    DATA total_available     TYPE i.
    DATA allocation_quantity TYPE i.
    DATA shortage_found      TYPE abap_bool VALUE abap_false.

    " This action is intended for one cart at a time
    DATA(key) = keys[ 1 ].

    " Read the cart
    READ ENTITIES OF zr_spac103_cart_dd_rwe IN LOCAL MODE
      ENTITY Cart
        FIELDS ( CartStatus )
        WITH VALUE #( ( %tky = key-%tky ) )
      RESULT DATA(carts).

    READ TABLE carts INTO DATA(cart)
      WITH TABLE KEY id COMPONENTS %tky = key-%tky.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " Only active, open carts can be checked out
    IF key-%tky-%is_draft = if_abap_behv=>mk-on
       OR cart-CartStatus <> 'O'.

      APPEND VALUE #(
        %tky = key-%tky
        %fail-cause = if_abap_behv=>cause-unspecific
      ) TO failed-cart.

      APPEND VALUE #(
        %tky = key-%tky
        %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text = 'Only active, open carts can be checked out.'
        )
        %action-Checkout = if_abap_behv=>mk-on
      ) TO reported-cart.

      RETURN.
    ENDIF.

    " Read all items belonging to the cart
    READ ENTITIES OF zr_spac103_cart_dd_rwe IN LOCAL MODE
      ENTITY Cart BY \_Items
        ALL FIELDS
        WITH VALUE #( ( %tky = key-%tky ) )
      RESULT DATA(cart_items).

    IF cart_items IS INITIAL.

      APPEND VALUE #(
        %tky = key-%tky
        %fail-cause = if_abap_behv=>cause-unspecific
      ) TO failed-cart.

      APPEND VALUE #(
        %tky = key-%tky
        %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text = 'Cannot check out an empty cart.'
        )
        %action-Checkout = if_abap_behv=>mk-on
      ) TO reported-cart.

      RETURN.
    ENDIF.

    " Validate quantities before doing anything else
    LOOP AT cart_items INTO DATA(cart_item).

      IF cart_item-Quantity <= 0.

        APPEND VALUE #(
          %tky = key-%tky
          %fail-cause = if_abap_behv=>cause-unspecific
        ) TO failed-cart.

        APPEND VALUE #(
          %tky = key-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = |Product { cart_item-ProductId } has an invalid quantity.|
          )
          %action-Checkout = if_abap_behv=>mk-on
        ) TO reported-cart.

        RETURN.
      ENDIF.

    ENDLOOP.

    " Find all stock entries belonging to the requested products
    " We collect their keys before locking and reading the actual amounts
    LOOP AT cart_items INTO cart_item.

      SELECT warehouse_id, product_id
        FROM zspac103_stock
        WHERE product_id = @cart_item-ProductId
        ORDER BY warehouse_id
        INTO TABLE @DATA(db_stock_keys).

      LOOP AT db_stock_keys INTO DATA(db_stock_key).

        APPEND VALUE #(
          WarehouseId = db_stock_key-warehouse_id
          ProductId   = db_stock_key-product_id
        ) TO stock_lock_keys.

      ENDLOOP.

    ENDLOOP.

    " Sort and remove duplicate stock keys
    SORT stock_lock_keys BY ProductId WarehouseId.

    DELETE ADJACENT DUPLICATES FROM stock_lock_keys
      COMPARING ProductId WarehouseId.

    " Lock all relevant stock entries
    IF stock_lock_keys IS NOT INITIAL.

      SET LOCKS OF zr_spac103_stock_dd_rwe
        ENTITY zr_spac103_stock_dd_rwe
        FROM stock_lock_keys
        FAILED DATA(failed_stock_locks).

      IF failed_stock_locks IS NOT INITIAL.

        APPEND VALUE #(
          %tky = key-%tky
          %fail-cause = if_abap_behv=>cause-unspecific
        ) TO failed-cart.

        APPEND VALUE #(
          %tky = key-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = 'Some stock entries are currently locked. Please try again.'
          )
          %action-Checkout = if_abap_behv=>mk-on
        ) TO reported-cart.

        RETURN.
      ENDIF.

    ENDIF.

    " Read the latest stock amounts after acquiring the locks
    READ ENTITIES OF zr_spac103_stock_dd_rwe
      ENTITY zr_spac103_stock_dd_rwe
        ALL FIELDS
        WITH CORRESPONDING #( stock_lock_keys )
      RESULT DATA(stock_records)
      FAILED DATA(failed_stock_reads).

    IF failed_stock_reads IS NOT INITIAL.

      APPEND VALUE #(
        %tky = key-%tky
        %fail-cause = if_abap_behv=>cause-unspecific
      ) TO failed-cart.

      APPEND VALUE #(
        %tky = key-%tky
        %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text = 'Could not read the current stock levels.'
        )
        %action-Checkout = if_abap_behv=>mk-on
      ) TO reported-cart.

      RETURN.
    ENDIF.

    " Sort stock so that lower warehouse IDs are used first
    SORT stock_records BY ProductId WarehouseId.

    " Calculate the allocation plan for every cart item
    " Nothing is modified at this stage
    LOOP AT cart_items INTO cart_item.

      remaining_quantity = cart_item-Quantity.
      total_available = 0.

      " Calculate total stock across all warehouses
      LOOP AT stock_records INTO DATA(stock_sum)
        WHERE ProductId = cart_item-ProductId.

        IF stock_sum-Amount > 0.
          total_available = total_available + stock_sum-Amount.
        ENDIF.

      ENDLOOP.

      " Check whether enough stock exists
      IF total_available < remaining_quantity.

        shortage_found = abap_true.

        APPEND VALUE #(
          ProductId = cart_item-ProductId
          Requested = cart_item-Quantity
          Available = total_available
        ) TO shortages.

        CONTINUE.
      ENDIF.

      " Allocate stock across warehouses
      LOOP AT stock_records INTO DATA(stock_candidate)
        WHERE ProductId = cart_item-ProductId
          AND Amount > 0.

        IF remaining_quantity <= 0.
          EXIT.
        ENDIF.

        allocation_quantity = COND #(
          WHEN stock_candidate-Amount < remaining_quantity
          THEN stock_candidate-Amount
          ELSE remaining_quantity
        ).

        " Remember the allocation
        APPEND VALUE #(
          ProductId = cart_item-ProductId
          WarehouseId = stock_candidate-WarehouseId
          AllocatedQuantity = allocation_quantity
        ) TO allocation_plan.

        " Prepare the corresponding stock update
        APPEND VALUE #(
          %tky = stock_candidate-%tky
          Amount = stock_candidate-Amount - allocation_quantity
        ) TO stock_updates.

        remaining_quantity =
          remaining_quantity - allocation_quantity.

      ENDLOOP.

    ENDLOOP.

    " If even one product has insufficient stock, abort before modifying anything
    IF shortage_found = abap_true.

      APPEND VALUE #(
        %tky = key-%tky
        %fail-cause = if_abap_behv=>cause-unspecific
      ) TO failed-cart.

      LOOP AT shortages INTO DATA(shortage).

        APPEND VALUE #(
          %tky = key-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = |P{ shortage-ProductId }: need { shortage-Requested }, have { shortage-Available }.|
          )
          %action-Checkout = if_abap_behv=>mk-on
        ) TO reported-cart.

      ENDLOOP.

      RETURN.
    ENDIF.

    " Prepare stock allocation records for all cart items
    LOOP AT cart_items INTO cart_item.

      APPEND VALUE #(
        CartUUID = cart_item-CartUUID
        ProductId = cart_item-ProductId
        %is_draft = if_abap_behv=>mk-off

        %target = VALUE #(
          FOR allocation IN allocation_plan
          WHERE ( ProductId = cart_item-ProductId )
          (
            %cid = |ALLOC_{ cart_item-ProductId }_{ allocation-WarehouseId }|
            %is_draft = if_abap_behv=>mk-off
            WarehouseId = allocation-WarehouseId
            AllocatedQuantity = allocation-AllocatedQuantity
          )
        )
      ) TO allocation_cba.

    ENDLOOP.

    " Create all stock allocation records
    MODIFY ENTITIES OF zr_spac103_cart_dd_rwe IN LOCAL MODE
      ENTITY Item
        CREATE BY \_Allocations
        FIELDS ( WarehouseId AllocatedQuantity )
        WITH allocation_cba
      FAILED DATA(failed_allocation_create).

    IF failed_allocation_create IS NOT INITIAL.

      APPEND VALUE #(
        %tky = key-%tky
        %fail-cause = if_abap_behv=>cause-unspecific
      ) TO failed-cart.

      APPEND VALUE #(
        %tky = key-%tky
        %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text = 'Could not create the stock allocations.'
        )
        %action-Checkout = if_abap_behv=>mk-on
      ) TO reported-cart.

      RETURN.
    ENDIF.

    " Update stock amounts in the separate Stock BO
    MODIFY ENTITIES OF zr_spac103_stock_dd_rwe
      ENTITY zr_spac103_stock_dd_rwe
        UPDATE FIELDS ( Amount )
        WITH stock_updates
      FAILED DATA(failed_stock_updates).

    IF failed_stock_updates IS NOT INITIAL.

      APPEND VALUE #(
        %tky = key-%tky
        %fail-cause = if_abap_behv=>cause-unspecific
      ) TO failed-cart.

      APPEND VALUE #(
        %tky = key-%tky
        %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text = 'Could not update the stock levels.'
        )
        %action-Checkout = if_abap_behv=>mk-on
      ) TO reported-cart.

      RETURN.
    ENDIF.

    " Mark the cart as completed
    MODIFY ENTITIES OF zr_spac103_cart_dd_rwe IN LOCAL MODE
      ENTITY Cart
        UPDATE FIELDS ( CartStatus )
        WITH VALUE #(
          (
            %tky = key-%tky
            CartStatus = 'C'
          )
        )
      FAILED DATA(failed_cart_update).

    IF failed_cart_update IS NOT INITIAL.

      APPEND VALUE #(
        %tky = key-%tky
        %fail-cause = if_abap_behv=>cause-unspecific
      ) TO failed-cart.

      APPEND VALUE #(
        %tky = key-%tky
        %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text = 'Could not complete the shopping cart.'
        )
        %action-Checkout = if_abap_behv=>mk-on
      ) TO reported-cart.

      RETURN.
    ENDIF.

    " Return the completed cart
    READ ENTITIES OF zr_spac103_cart_dd_rwe IN LOCAL MODE
      ENTITY Cart
        ALL FIELDS
        WITH VALUE #( ( %tky = key-%tky ) )
      RESULT DATA(updated_carts).

    LOOP AT updated_carts INTO DATA(updated_cart).

      APPEND VALUE #(
        %tky = updated_cart-%tky
        %param = CORRESPONDING #( updated_cart )
      ) TO result.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
