  METHOD zc_businesspartn_update_entity.

    DATA: ls_bp_id              TYPE bapi_epm_bp_id,
          ls_headerdata_update  TYPE bapi_epm_bp_header,
          ls_headerdatax        TYPE bapi_epm_bp_headerx,
          lt_return             TYPE TABLE OF bapiret2,
          ls_return             TYPE bapiret2,
          err_msg               TYPE string,
          ls_message            TYPE scx_t100key,
          ls_headerdata_key     TYPE zcl_zcds_rds_mpc=>ts_zi_businesspartner_examplet,
          ls_headerdata_payload TYPE zcl_zcds_rds_mpc=>ts_zi_businesspartner_examplet.


    CALL METHOD io_tech_request_context->get_converted_keys
      IMPORTING
        es_key_values = ls_headerdata_key.

    io_data_provider->read_entry_data( IMPORTING es_data = ls_headerdata_payload ).

    MOVE ls_headerdata_key-businesspartnerid TO ls_bp_id-bp_id.

    MOVE ls_headerdata_key-businesspartnerid TO ls_headerdatax-bp_id.
    MOVE 'X' TO ls_headerdatax-company_name.
    MOVE 'X' TO ls_headerdatax-legal_form.
    MOVE 'X' TO ls_headerdatax-city.
    MOVE 'X' TO ls_headerdatax-country.
    MOVE 'X' TO ls_headerdatax-street.
    MOVE 'X' TO ls_headerdatax-building.
    MOVE ls_headerdata_key-businesspartnerid TO ls_headerdata_update-bp_id.
    MOVE ls_headerdata_payload-companyname TO ls_headerdata_update-company_name.
    MOVE ls_headerdata_payload-legalform TO ls_headerdata_update-legal_form.
    MOVE ls_headerdata_payload-city TO ls_headerdata_update-city.
    MOVE ls_headerdata_payload-countryid TO ls_headerdata_update-country.
    MOVE ls_headerdata_payload-street TO ls_headerdata_update-street.
    MOVE ls_headerdata_payload-building TO ls_headerdata_update-building.

    CALL FUNCTION 'BAPI_EPM_BP_CHANGE'
      EXPORTING
        bp_id       = ls_bp_id
        headerdata  = ls_headerdata_update
        headerdatax = ls_headerdatax
      TABLES
        return      = lt_return.

    IF lt_return IS NOT INITIAL.

      mo_context->get_message_container( )->add_messages_from_bapi(
        it_bapi_messages          = lt_return
        iv_determine_leading_msg  = /iwbep/if_message_container=>gcs_leading_msg_search_option-first   ).

        RAISE EXCEPTION TYPE  ZCX_BUPA_BUSI_EXCEPTION.
        ENDIF.

    ENDMETHOD.