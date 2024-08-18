  method SALESORDERLINEIT_GET_ENTITYSET.
*-------------------------------------------------------------
*  Data declaration
*-------------------------------------------------------------
 DATA so_id TYPE zif_bapi_epm_so_get_detail=>bapi_epm_so_id.
 DATA itemdata  TYPE zif_bapi_epm_so_get_detail=>__bapi_epm_so_item.
 DATA return  TYPE zif_bapi_epm_so_get_detail=>__bapiret2.
 DATA ls_itemdata  TYPE LINE OF zif_bapi_epm_so_get_detail=>__bapi_epm_so_item.
 DATA ls_return  TYPE LINE OF zif_bapi_epm_so_get_detail=>__bapiret2.
 DATA lv_rfc_name TYPE tfdir-funcname.
 DATA lv_destination TYPE rfcdest.
 DATA lv_subrc TYPE syst-subrc.
 DATA lv_exc_msg TYPE /iwbep/mgw_bop_rfc_excep_text.
 DATA lx_root TYPE REF TO cx_root.
 DATA lo_filter TYPE  REF TO /iwbep/if_mgw_req_filter.
 DATA lt_filter_select_options TYPE /iwbep/t_mgw_select_option.
 DATA lv_filter_str TYPE string.
 DATA ls_paging TYPE /iwbep/s_mgw_paging.
 DATA ls_converted_keys LIKE LINE OF et_entityset.
 DATA lv_source_entity_set_name TYPE string.
 DATA salesorderheader_get_entityset TYPE LINE OF zcl_zrfc1_mpc=>tt_salesorderheader.
 DATA ls_filter TYPE /iwbep/s_mgw_select_option.
 DATA ls_filter_range TYPE /iwbep/s_cod_select_option.
 DATA lr_so_id LIKE RANGE OF ls_converted_keys-so_id.
 DATA ls_so_id LIKE LINE OF lr_so_id.
 DATA lo_dp_facade TYPE REF TO /iwbep/if_mgw_dp_facade.
 DATA ls_gw_itemdata LIKE LINE OF et_entityset.
 DATA lv_skip     TYPE int4.
 DATA lv_top      TYPE int4.

*-------------------------------------------------------------
*  Map the runtime request to the RFC - Only mapped attributes
*-------------------------------------------------------------
* Get all input information from the technical request context object
* Since DPC works with internal property names and runtime API interface holds external property names
* the process needs to get the all needed input information from the technical request context object
* Get filter or select option information
 lo_filter = io_tech_request_context->get_filter( ).
 lt_filter_select_options = lo_filter->get_filter_select_options( ).
 lv_filter_str = lo_filter->get_filter_string( ).

* Check if the supplied filter is supported by standard gateway runtime process
 IF  lv_filter_str            IS NOT INITIAL
 AND lt_filter_select_options IS INITIAL.
   " If the string of the Filter System Query Option is not automatically converted into
   " filter option table (lt_filter_select_options), then the filtering combination is not supported
   " Log message in the application log
   me->/iwbep/if_sb_dpc_comm_services~log_message(
     EXPORTING
       iv_msg_type   = 'E'
       iv_msg_id     = '/IWBEP/MC_SB_DPC_ADM'
       iv_msg_number = 025 ).
   " Raise Exception
   RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
     EXPORTING
       textid = /iwbep/cx_mgw_tech_exception=>internal_error.
 ENDIF.

* Get key table information
 io_tech_request_context->get_converted_source_keys(
   IMPORTING
     es_key_values = ls_converted_keys ).

 ls_paging-top = io_tech_request_context->get_top( ).
 ls_paging-skip = io_tech_request_context->get_skip( ).

* Maps key fields to function module parameters
 IF it_key_tab IS NOT INITIAL.

   lv_source_entity_set_name = io_tech_request_context->get_source_entity_set_name( ).

   IF  lv_source_entity_set_name = 'SalesOrderHeaderSet'.
     " Convert keys to appropriate entity set structure
     io_tech_request_context->get_converted_source_keys(
       IMPORTING
         es_key_values = salesorderheader_get_entityset ).
     so_id-so_id = salesorderheader_get_entityset-so_id.
   ENDIF.

 ENDIF.

 IF it_filter_select_options IS NOT INITIAL.

* Maps filter table lines to function module parameters
   LOOP AT lt_filter_select_options INTO ls_filter.

     LOOP AT ls_filter-select_options INTO ls_filter_range.
       CASE ls_filter-property.
         WHEN 'SO_ID'.
           lo_filter->convert_select_option(
             EXPORTING
               is_select_option = ls_filter
             IMPORTING
               et_select_option = lr_so_id ).

           READ TABLE lr_so_id INTO ls_so_id INDEX 1.
           IF sy-subrc = 0.
             so_id-so_id = ls_so_id-low.
           ENDIF.
         WHEN OTHERS.
           " Log message in the application log
           me->/iwbep/if_sb_dpc_comm_services~log_message(
             EXPORTING
               iv_msg_type   = 'E'
               iv_msg_id     = '/IWBEP/MC_SB_DPC_ADM'
               iv_msg_number = 020
               iv_msg_v1     = ls_filter-property ).
           " Raise Exception
           RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
             EXPORTING
               textid = /iwbep/cx_mgw_tech_exception=>internal_error.
       ENDCASE.
     ENDLOOP.

   ENDLOOP.

 ENDIF.

* Get RFC destination
 lo_dp_facade = /iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).
 lv_destination = /iwbep/cl_sb_gen_dpc_rt_util=>get_rfc_destination( io_dp_facade = lo_dp_facade ).

*-------------------------------------------------------------
*  Call RFC function module
*-------------------------------------------------------------
 lv_rfc_name = 'BAPI_EPM_SO_GET_DETAIL'.

 IF lv_destination IS INITIAL OR lv_destination EQ 'NONE'.

   TRY.
       CALL FUNCTION lv_rfc_name
         EXPORTING
           so_id          = so_id
         TABLES
           return         = return
           itemdata       = itemdata
         EXCEPTIONS
           system_failure = 1000 message lv_exc_msg
           OTHERS         = 1002.

       lv_subrc = sy-subrc.
*in case of co-deployment the exception is raised and needs to be caught
     CATCH cx_root INTO lx_root.
       lv_subrc = 1001.
       lv_exc_msg = lx_root->if_message~get_text( ).
   ENDTRY.

 ELSE.

   CALL FUNCTION lv_rfc_name DESTINATION lv_destination
     EXPORTING
       so_id                 = so_id
     TABLES
       return                = return
       itemdata              = itemdata
     EXCEPTIONS
       system_failure        = 1000 MESSAGE lv_exc_msg
       communication_failure = 1001 MESSAGE lv_exc_msg
       OTHERS                = 1002.

   lv_subrc = sy-subrc.

 ENDIF.

*-------------------------------------------------------------
*  Map the RFC response to the caller interface - Only mapped attributes
*-------------------------------------------------------------
*-------------------------------------------------------------
* Error and exception handling
*-------------------------------------------------------------
 IF lv_subrc <> 0.
* Execute the RFC exception handling process
   me->/iwbep/if_sb_dpc_comm_services~rfc_exception_handling(
     EXPORTING
       iv_subrc            = lv_subrc
       iv_exp_message_text = lv_exc_msg ).
 ENDIF.

 IF return IS NOT INITIAL.
   me->/iwbep/if_sb_dpc_comm_services~rfc_save_log(
     EXPORTING
       iv_entity_type = iv_entity_name
       it_return      = return
       it_key_tab     = it_key_tab ).
 ENDIF.

*-------------------------------------------------------------------------*
*             - Post Backend Call -
*-------------------------------------------------------------------------*
 IF ls_paging-skip IS NOT INITIAL.
*  If the Skip value was requested at runtime
*  the response table will provide backend entries from skip + 1, meaning start from skip +1
*  for example: skip=5 means to start get results from the 6th row
   lv_skip = ls_paging-skip + 1.
 ENDIF.
*  The Top value was requested at runtime but was not handled as part of the function interface
 IF  ls_paging-top <> 0
 AND lv_skip IS NOT INITIAL.
*  if lv_skip > 0 retrieve the entries from lv_skip + Top - 1
*  for example: skip=5 and top=2 means to start get results from the 6th row and end in row number 7
   lv_top = ls_paging-top + lv_skip - 1.
 ELSEIF ls_paging-top <> 0
 AND    lv_skip IS INITIAL.
   lv_top = ls_paging-top.
 ELSE.
   lv_top = lines( itemdata ).
 ENDIF.

*  - Map properties from the backend to the Gateway output response table -

 LOOP AT itemdata INTO ls_itemdata
*  Provide the response entries according to the Top and Skip parameters that were provided at runtime
      FROM lv_skip TO lv_top.
*  Only fields that were mapped will be delivered to the response table
   ls_gw_itemdata-quantity_unit = ls_itemdata-quantity_unit.
   ls_gw_itemdata-quantity = ls_itemdata-quantity.
   ls_gw_itemdata-delivery_date = ls_itemdata-delivery_date.
   ls_gw_itemdata-tax_amount_ext = ls_itemdata-tax_amount_ext.
   ls_gw_itemdata-tax_amount = ls_itemdata-tax_amount.
   ls_gw_itemdata-net_amount_ext = ls_itemdata-net_amount_ext.
   ls_gw_itemdata-net_amount = ls_itemdata-net_amount.
   ls_gw_itemdata-gross_amount_ext = ls_itemdata-gross_amount_ext.
   ls_gw_itemdata-gross_amount = ls_itemdata-gross_amount.
   ls_gw_itemdata-currency_code = ls_itemdata-currency_code.
   ls_gw_itemdata-note = ls_itemdata-note.
   ls_gw_itemdata-product_id = ls_itemdata-product_id.
   ls_gw_itemdata-so_item_pos = ls_itemdata-so_item_pos.
   ls_gw_itemdata-so_id = ls_itemdata-so_id.
   APPEND ls_gw_itemdata TO et_entityset.
   CLEAR ls_gw_itemdata.
 ENDLOOP.

  endmethod.