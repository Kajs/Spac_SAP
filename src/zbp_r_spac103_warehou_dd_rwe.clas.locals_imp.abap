CLASS lhc_ZR_SPAC103_WAREHOU_DD_RWE DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR zr_spac103_warehou_dd_rwe RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR zr_spac103_warehou_dd_rwe RESULT result.

ENDCLASS.

CLASS lhc_ZR_SPAC103_WAREHOU_DD_RWE IMPLEMENTATION.

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
