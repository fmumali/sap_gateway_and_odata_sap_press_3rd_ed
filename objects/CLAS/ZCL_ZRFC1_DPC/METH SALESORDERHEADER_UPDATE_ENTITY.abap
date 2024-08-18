  method SALESORDERHEADER_UPDATE_ENTITY.
*-------------------------------------------------------------
*  Data declaration
*-------------------------------------------------------------
 DATA soheaderdata TYPE zif_bapi_epm_so_change=>bapi_epm_so_header.
 DATA soheaderdatax TYPE zif_bapi_epm_so_change=>bapi_epm_so_headerx.
 DATA so_id TYPE zif_bapi_epm_so_change=>bapi_epm_so_id.
 DATA return  TYPE zif_bapi_epm_so_change=>__bapiret2.
 DATA ls_return  TYPE LINE OF zif_bapi_epm_so_change=>__bapiret2.
 DATA lv_rfc_name TYPE tfdir-funcname.
 DATA lv_destination TYPE rfcdest.
 DATA lv_subrc TYPE syst-subrc.
 DATA lv_exc_msg TYPE /iwbep/mgw_bop_rfc_excep_text.
 DATA lx_root TYPE REF TO cx_root.
 DATA ls_request_input_data TYPE zcl_zrfc1_mpc=>ts_salesorderheader.
 DATA ls_converted_keys LIKE er_entity.
 DATA lv_source_entity_set_name TYPE string.
 DATA lo_dp_facade TYPE REF TO /iwbep/if_mgw_dp_facade.

*-------------------------------------------------------------
*  Map the runtime request to the RFC - Only mapped attributes
*-------------------------------------------------------------
* Get all input information from the technical request context object
* Since DPC works with internal property names and runtime API interface holds external property names
* the process needs to get the all needed input information from the technical request context object
* Get request input data
 io_data_provider->read_entry_data( IMPORTING es_data = ls_request_input_data ).
* Get key table information
 io_tech_request_context->get_converted_keys(
   IMPORTING
     es_key_values = ls_converted_keys ).

* Maps constant value to function module parameters
 soheaderdatax-currency_code = 'X'.
 soheaderdatax-buyer_name = 'X'.
 soheaderdatax-buyer_id = 'X'.
 soheaderdatax-note = 'X'.

* Maps key fields to function module parameters

 soheaderdata-so_id = ls_converted_keys-so_id.
 soheaderdatax-so_id = ls_converted_keys-so_id.
 so_id-so_id = ls_converted_keys-so_id.
* Map request input fields to function module parameters
 soheaderdata-delivery_status = ls_request_input_data-delivery_status.
 soheaderdata-billing_status = ls_request_input_data-billing_status.
 soheaderdata-lifecycle_status = ls_request_input_data-lifecycle_status.
 soheaderdata-tax_amount_ext = ls_request_input_data-tax_amount_ext.
 soheaderdata-tax_amount = ls_request_input_data-tax_amount.
 soheaderdata-net_amount_ext = ls_request_input_data-net_amount_ext.
 soheaderdata-net_amount = ls_request_input_data-net_amount.
 soheaderdata-gross_amount_ext = ls_request_input_data-gross_amount_ext.
 soheaderdata-gross_amount = ls_request_input_data-gross_amount.
 soheaderdata-currency_code = ls_request_input_data-currency_code.
 soheaderdata-buyer_name = ls_request_input_data-buyer_name.
 soheaderdata-buyer_id = ls_request_input_data-buyer_id.
 soheaderdata-note = ls_request_input_data-note.
 soheaderdata-changed_by_bp = ls_request_input_data-changed_by_bp.
 soheaderdata-created_by_bp = ls_request_input_data-created_by_bp.
 soheaderdata-changed_at = ls_request_input_data-changed_at.
 soheaderdata-changed_by = ls_request_input_data-changed_by.
 soheaderdata-created_at = ls_request_input_data-created_at.
 soheaderdata-created_by = ls_request_input_data-created_by.

* Get RFC destination
 lo_dp_facade = /iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).
 lv_destination = /iwbep/cl_sb_gen_dpc_rt_util=>get_rfc_destination( io_dp_facade = lo_dp_facade ).

*-------------------------------------------------------------
*  Call RFC function module
*-------------------------------------------------------------
 lv_rfc_name = 'BAPI_EPM_SO_CHANGE'.

 IF lv_destination IS INITIAL OR lv_destination EQ 'NONE'.

   TRY.
       CALL FUNCTION lv_rfc_name
         EXPORTING
           soheaderdatax  = soheaderdatax
           so_id          = so_id
           soheaderdata   = soheaderdata
         TABLES
           return         = return
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
       soheaderdatax         = soheaderdatax
       so_id                 = so_id
       soheaderdata          = soheaderdata
     TABLES
       return                = return
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

* Call RFC commit work
 me->/iwbep/if_sb_dpc_comm_services~commit_work(
   EXPORTING
     iv_rfc_dest = lv_destination
 ).
  endmethod.