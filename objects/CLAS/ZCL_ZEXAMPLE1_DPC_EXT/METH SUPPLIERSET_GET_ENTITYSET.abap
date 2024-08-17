  METHOD supplierset_get_entityset.

    DATA: ls_bpheaderdata TYPE bapi_epm_bp_header,
          lt_bpheaderdata TYPE STANDARD TABLE OF bapi_epm_bp_header,
          ls_supplier     LIKE LINE OF et_entityset.

    CALL FUNCTION 'BAPI_EPM_BP_GET_LIST'
      TABLES
        bpheaderdata = lt_bpheaderdata.

    LOOP AT lt_bpheaderdata INTO ls_bpheaderdata.

      ls_supplier-supplierid  = ls_bpheaderdata-bp_id.
      ls_supplier-suppliername  = ls_bpheaderdata-company_name.
      APPEND ls_supplier TO et_entityset.

    ENDLOOP.

  ENDMETHOD.