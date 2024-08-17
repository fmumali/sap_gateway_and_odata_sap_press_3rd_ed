  METHOD productset_get_entityset.

    DATA: lr_filter                TYPE REF TO /iwbep/if_mgw_req_filter,
          lt_filter_select_options TYPE /iwbep/t_mgw_select_option,
          ls_filter_select_options TYPE /iwbep/s_mgw_select_option,
          ls_select_option         TYPE /iwbep/s_cod_select_option,
          lt_selparamproductid     TYPE STANDARD TABLE OF bapi_epm_product_id_range,
          ls_selparamproductid     TYPE bapi_epm_product_id_range,
          lt_selparamcategories    TYPE STANDARD TABLE OF bapi_epm_product_categ_range,
          ls_selparamcategories    TYPE bapi_epm_product_categ_range.

    DATA: ls_headerdata TYPE bapi_epm_product_header,
          lt_headerdata TYPE STANDARD TABLE OF bapi_epm_product_header,
          ls_product    LIKE LINE OF et_entityset.

    lr_filter = io_tech_request_context->get_filter( ).
    lt_filter_select_options = lr_filter->get_filter_select_options( ).

    LOOP AT lt_filter_select_options INTO ls_filter_select_options.
      IF ls_filter_select_options-property EQ 'PRODUCTID'.
        LOOP AT ls_filter_select_options-select_options INTO ls_select_option.
          ls_selparamproductid-sign
          = ls_select_option-sign.
          ls_selparamproductid-option = ls_select_option-option.
          ls_selparamproductid-low
          = ls_select_option-low.
          ls_selparamproductid-high
          = ls_select_option-high.
          APPEND ls_selparamproductid TO lt_selparamproductid.
        ENDLOOP.

      ELSEIF ls_filter_select_options-property EQ 'CATEGORY'.
        LOOP AT ls_filter_select_options-select_options INTO ls_select_option.
          ls_selparamcategories-sign   = ls_select_option-sign.
          ls_selparamcategories-option = ls_select_option-option.
          ls_selparamcategories-low    = ls_select_option-low.
          ls_selparamcategories-high   = ls_select_option-high.
          APPEND ls_selparamcategories TO lt_selparamcategories.
        ENDLOOP.

      ENDIF.
    ENDLOOP.


    CALL FUNCTION 'BAPI_EPM_PRODUCT_GET_LIST'
      TABLES
        headerdata         = lt_headerdata
        selparamproductidb = lt_selparamproductid.


    LOOP AT lt_headerdata INTO ls_headerdata.

      ls_product-productid = ls_headerdata-product_id.
      ls_product-category = ls_headerdata-category.
      ls_product-name = ls_headerdata-name.
      APPEND ls_product TO et_entityset.

    ENDLOOP.


  ENDMETHOD.