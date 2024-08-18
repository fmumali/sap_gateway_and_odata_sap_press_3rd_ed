  method SALESORDERHEADER_CREATE_ENTITY.
*-------------------------------------------------------------
*  Data declaration
*-------------------------------------------------------------
 DATA headerdata TYPE zif_bapi_epm_so_create=>bapi_epm_so_header.
 DATA salesorderid TYPE zif_bapi_epm_so_create=>bapi_epm_so_id.
 DATA return  TYPE zif_bapi_epm_so_create=>__bapiret2.
 DATA ls_return  TYPE LINE OF zif_bapi_epm_so_create=>__bapiret2.
 DATA lv_rfc_name TYPE tfdir-funcname.
 DATA lv_destination TYPE rfcdest.
 DATA lv_subrc TYPE syst-subrc.
 DATA lv_exc_msg TYPE /iwbep/mgw_bop_rfc_excep_text.
 DATA lx_root TYPE REF TO cx_root.
 DATA ls_request_input_data TYPE zcl_zrfc1_mpc=>ts_salesorderheader.
 DATA ls_entity TYPE REF TO data.
 DATA lo_tech_read_request_context TYPE REF TO /iwbep/cl_sb_gen_read_aftr_crt.
 DATA ls_key TYPE /iwbep/s_mgw_tech_pair.
 DATA lt_keys TYPE /iwbep/t_mgw_tech_pairs.
 DATA lv_entityset_name TYPE string.
 DATA lv_entity_name TYPE string.
 FIELD-SYMBOLS: <ls_data> TYPE any.
 DATA ls_converted_keys LIKE er_entity.
 DATA lo_dp_facade TYPE REF TO /iwbep/if_mgw_dp_facade.

*-------------------------------------------------------------
*  Map the runtime request to the RFC - Only mapped attributes
*-------------------------------------------------------------
* Get all input information from the technical request context object
* Since DPC works with internal property names and runtime API interface holds external property names
* the process needs to get the all needed input information from the technical request context object
* Get request input data
 io_data_provider->read_entry_data( IMPORTING es_data = ls_request_input_data ).

* Map request input fields to function module parameters
 headerdata-so_id = ls_request_input_data-so_id.
 headerdata-delivery_status = ls_request_input_data-delivery_status.
 headerdata-billing_status = ls_request_input_data-billing_status.
 headerdata-lifecycle_status = ls_request_input_data-lifecycle_status.
 headerdata-tax_amount_ext = ls_request_input_data-tax_amount_ext.
 headerdata-tax_amount = ls_request_input_data-tax_amount.
 headerdata-net_amount_ext = ls_request_input_data-net_amount_ext.
 headerdata-net_amount = ls_request_input_data-net_amount.
 headerdata-gross_amount_ext = ls_request_input_data-gross_amount_ext.
 headerdata-gross_amount = ls_request_input_data-gross_amount.
 headerdata-currency_code = ls_request_input_data-currency_code.
 headerdata-buyer_name = ls_request_input_data-buyer_name.
 headerdata-buyer_id = ls_request_input_data-buyer_id.
 headerdata-note = ls_request_input_data-note.
 headerdata-changed_by_bp = ls_request_input_data-changed_by_bp.
 headerdata-created_by_bp = ls_request_input_data-created_by_bp.
 headerdata-changed_at = ls_request_input_data-changed_at.
 headerdata-changed_by = ls_request_input_data-changed_by.
 headerdata-created_at = ls_request_input_data-created_at.
 headerdata-created_by = ls_request_input_data-created_by.

* Get RFC destination
 lo_dp_facade = /iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).
 lv_destination = /iwbep/cl_sb_gen_dpc_rt_util=>get_rfc_destination( io_dp_facade = lo_dp_facade ).

*-------------------------------------------------------------
*  Call RFC function module
*-------------------------------------------------------------
 lv_rfc_name = 'BAPI_EPM_SO_CREATE'.

 IF lv_destination IS INITIAL OR lv_destination EQ 'NONE'.

   TRY.
       CALL FUNCTION lv_rfc_name
         EXPORTING
           headerdata     = headerdata
         IMPORTING
           salesorderid   = salesorderid
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
       headerdata            = headerdata
     IMPORTING
       salesorderid          = salesorderid
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
*-------------------------------------------------------------------------*
*             - Read After Create -
*-------------------------------------------------------------------------*
 CREATE OBJECT lo_tech_read_request_context.

* Create key table for the read operation

 ls_key-name = 'SO_ID'.
 ls_key-value = headerdata-so_id.
 IF ls_key IS NOT INITIAL.
   APPEND ls_key TO lt_keys.
 ENDIF.

 ls_key-name = 'SO_ID'.
 ls_key-value = salesorderid-so_id.
 IF ls_key IS NOT INITIAL.
   APPEND ls_key TO lt_keys.
 ENDIF.

* Set into request context object the key table and the entity set name
 lo_tech_read_request_context->set_keys( EXPORTING  it_keys = lt_keys ).
 lv_entityset_name = io_tech_request_context->get_entity_set_name( ).
 lo_tech_read_request_context->set_entityset_name( EXPORTING iv_entityset_name = lv_entityset_name ).
 lv_entity_name = io_tech_request_context->get_entity_type_name( ).
 lo_tech_read_request_context->set_entity_type_name( EXPORTING iv_entity_name = lv_entity_name ).

* Call read after create
 /iwbep/if_mgw_appl_srv_runtime~get_entity(
   EXPORTING
     iv_entity_name          = iv_entity_name
     iv_entity_set_name      = iv_entity_set_name
     iv_source_name          = iv_source_name
     it_key_tab              = it_key_tab
     io_tech_request_context = lo_tech_read_request_context
     it_navigation_path      = it_navigation_path
   IMPORTING
     er_entity               = ls_entity ).

* Send the read response to the caller interface
 ASSIGN ls_entity->* TO <ls_data>.
 er_entity = <ls_data>.
  endmethod.