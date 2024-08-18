  method SALESORDERLINEIT_CREATE_ENTITY.
*-------------------------------------------------------------
*  Data declaration
*-------------------------------------------------------------
 DATA soitemdata TYPE zif_z_bapi_epm_so_item_create=>bapi_epm_so_item.
 DATA soitemdatax TYPE zif_z_bapi_epm_so_item_create=>bapi_epm_so_itemx.
 DATA so_id TYPE zif_z_bapi_epm_so_item_create=>snwd_so_id.
 DATA so_item_pos TYPE zif_z_bapi_epm_so_item_create=>snwd_so_item_pos.
 DATA return  TYPE zif_z_bapi_epm_so_item_create=>__bapiret2.
 DATA ls_return  TYPE LINE OF zif_z_bapi_epm_so_item_create=>__bapiret2.
 DATA lv_rfc_name TYPE tfdir-funcname.
 DATA lv_destination TYPE rfcdest.
 DATA lv_subrc TYPE syst-subrc.
 DATA lv_exc_msg TYPE /iwbep/mgw_bop_rfc_excep_text.
 DATA lx_root TYPE REF TO cx_root.
 DATA ls_request_input_data TYPE zcl_zrfc1_mpc=>ts_salesorderlineitem.
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

* Maps constant value to function module parameters
 soitemdatax-actioncode = 'I'.
 soitemdatax-quantity_unit = 'X'.
 soitemdatax-quantity = 'X'.
 soitemdatax-note = 'X'.

* Map request input fields to function module parameters
 so_id = ls_request_input_data-so_id.
 soitemdata-quantity_unit = ls_request_input_data-quantity_unit.
 soitemdata-quantity = ls_request_input_data-quantity.
 soitemdata-delivery_date = ls_request_input_data-delivery_date.
 soitemdata-tax_amount_ext = ls_request_input_data-tax_amount_ext.
 soitemdata-tax_amount = ls_request_input_data-tax_amount.
 soitemdata-net_amount_ext = ls_request_input_data-net_amount_ext.
 soitemdata-net_amount = ls_request_input_data-net_amount.
 soitemdata-gross_amount_ext = ls_request_input_data-gross_amount_ext.
 soitemdata-gross_amount = ls_request_input_data-gross_amount.
 soitemdata-currency_code = ls_request_input_data-currency_code.
 soitemdata-note = ls_request_input_data-note.
 soitemdata-product_id = ls_request_input_data-product_id.

* Get RFC destination
 lo_dp_facade = /iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).
 lv_destination = /iwbep/cl_sb_gen_dpc_rt_util=>get_rfc_destination( io_dp_facade = lo_dp_facade ).

*-------------------------------------------------------------
*  Call RFC function module
*-------------------------------------------------------------
 lv_rfc_name = 'Z_BAPI_EPM_SO_ITEM_CREATE'.

 IF lv_destination IS INITIAL OR lv_destination EQ 'NONE'.

   TRY.
       CALL FUNCTION lv_rfc_name
         EXPORTING
           soitemdatax    = soitemdatax
           soitemdata     = soitemdata
           so_id          = so_id
         IMPORTING
           so_item_pos    = so_item_pos
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
       soitemdatax           = soitemdatax
       soitemdata            = soitemdata
       so_id                 = so_id
     IMPORTING
       so_item_pos           = so_item_pos
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
 ls_key-value = so_id.
 IF ls_key-value IS NOT INITIAL.
   APPEND ls_key TO lt_keys.
 ENDIF.

 ls_key-name = 'SO_ITEM_POS'.
 ls_key-value = so_item_pos.
 IF ls_key-value IS NOT INITIAL.
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