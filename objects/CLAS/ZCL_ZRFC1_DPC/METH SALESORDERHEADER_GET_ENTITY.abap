  method SALESORDERHEADER_GET_ENTITY.
*-------------------------------------------------------------
*  Data declaration
*-------------------------------------------------------------
 DATA headerdata TYPE zif_bapi_epm_so_get_detail=>bapi_epm_so_header.
 DATA so_id TYPE zif_bapi_epm_so_get_detail=>bapi_epm_so_id.
 DATA return  TYPE zif_bapi_epm_so_get_detail=>__bapiret2.
 DATA ls_return  TYPE LINE OF zif_bapi_epm_so_get_detail=>__bapiret2.
 DATA lv_rfc_name TYPE tfdir-funcname.
 DATA lv_destination TYPE rfcdest.
 DATA lv_subrc TYPE syst-subrc.
 DATA lv_exc_msg TYPE /iwbep/mgw_bop_rfc_excep_text.
 DATA lx_root TYPE REF TO cx_root.
 DATA ls_converted_keys LIKE er_entity.
 DATA lv_source_entity_set_name TYPE string.
 DATA lo_dp_facade TYPE REF TO /iwbep/if_mgw_dp_facade.

*-------------------------------------------------------------
*  Map the runtime request to the RFC - Only mapped attributes
*-------------------------------------------------------------
* Get all input information from the technical request context object
* Since DPC works with internal property names and runtime API interface holds external property names
* the process needs to get the all needed input information from the technical request context object
* Get key table information - for direct call
 io_tech_request_context->get_converted_keys(
   IMPORTING
     es_key_values = ls_converted_keys ).

* Maps key fields to function module parameters

 lv_source_entity_set_name = io_tech_request_context->get_source_entity_set_name( ).

 IF lv_source_entity_set_name = 'SalesOrderHeaderSet' AND
    lv_source_entity_set_name NE io_tech_request_context->get_entity_set_name( ).

   io_tech_request_context->get_converted_source_keys(
     IMPORTING
       es_key_values = ls_converted_keys ).

 ENDIF.

 so_id-so_id = ls_converted_keys-so_id.
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
         IMPORTING
           headerdata     = headerdata
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
       so_id                 = so_id
     IMPORTING
       headerdata            = headerdata
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

*-------------------------------------------------------------------------*
*             - Post Backend Call -
*-------------------------------------------------------------------------*
* Map properties from the backend to the Gateway output response structure

 er_entity-delivery_status = headerdata-delivery_status.
 er_entity-billing_status = headerdata-billing_status.
 er_entity-lifecycle_status = headerdata-lifecycle_status.
 er_entity-tax_amount_ext = headerdata-tax_amount_ext.
 er_entity-tax_amount = headerdata-tax_amount.
 er_entity-net_amount_ext = headerdata-net_amount_ext.
 er_entity-net_amount = headerdata-net_amount.
 er_entity-gross_amount_ext = headerdata-gross_amount_ext.
 er_entity-gross_amount = headerdata-gross_amount.
 er_entity-currency_code = headerdata-currency_code.
 er_entity-buyer_name = headerdata-buyer_name.
 er_entity-buyer_id = headerdata-buyer_id.
 er_entity-note = headerdata-note.
 er_entity-changed_by_bp = headerdata-changed_by_bp.
 er_entity-created_by_bp = headerdata-created_by_bp.
 er_entity-changed_at = headerdata-changed_at.
 er_entity-changed_by = headerdata-changed_by.
 er_entity-created_at = headerdata-created_at.
 er_entity-created_by = headerdata-created_by.
 er_entity-so_id = headerdata-so_id.
  endmethod.