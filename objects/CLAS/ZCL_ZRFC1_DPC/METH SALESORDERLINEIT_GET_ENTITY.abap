  method SALESORDERLINEIT_GET_ENTITY.
*-------------------------------------------------------------
*  Data declaration
*-------------------------------------------------------------
 DATA so_id TYPE zif_z_bapi_epm_so_item_get_det=>snwd_so_id.
 DATA so_item_pos TYPE zif_z_bapi_epm_so_item_get_det=>snwd_so_item_pos.
 DATA itemdata  TYPE zif_z_bapi_epm_so_item_get_det=>__bapi_epm_so_item.
 DATA return  TYPE zif_z_bapi_epm_so_item_get_det=>__bapiret2.
 DATA ls_itemdata  TYPE LINE OF zif_z_bapi_epm_so_item_get_det=>__bapi_epm_so_item.
 DATA ls_return  TYPE LINE OF zif_z_bapi_epm_so_item_get_det=>__bapiret2.
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

 IF lv_source_entity_set_name = 'SalesOrderLineItemSet' AND
    lv_source_entity_set_name NE io_tech_request_context->get_entity_set_name( ).

   io_tech_request_context->get_converted_source_keys(
     IMPORTING
       es_key_values = ls_converted_keys ).

 ENDIF.

 so_item_pos = ls_converted_keys-so_item_pos.
 so_id = ls_converted_keys-so_id.
* Get RFC destination
 lo_dp_facade = /iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).
 lv_destination = /iwbep/cl_sb_gen_dpc_rt_util=>get_rfc_destination( io_dp_facade = lo_dp_facade ).

*-------------------------------------------------------------
*  Call RFC function module
*-------------------------------------------------------------
 lv_rfc_name = 'Z_BAPI_EPM_SO_ITEM_GET_DETAIL'.

 IF lv_destination IS INITIAL OR lv_destination EQ 'NONE'.

   TRY.
       CALL FUNCTION lv_rfc_name
         EXPORTING
           so_item_pos    = so_item_pos
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
       so_item_pos           = so_item_pos
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
* Map properties from the backend to the Gateway output response structure


* In GetEntity operation we support only read for the first entry in the response table

 READ TABLE itemdata INTO ls_itemdata INDEX 1.
 er_entity-quantity_unit = ls_itemdata-quantity_unit.
 er_entity-quantity = ls_itemdata-quantity.
 er_entity-delivery_date = ls_itemdata-delivery_date.
 er_entity-tax_amount_ext = ls_itemdata-tax_amount_ext.
 er_entity-tax_amount = ls_itemdata-tax_amount.
 er_entity-net_amount_ext = ls_itemdata-net_amount_ext.
 er_entity-net_amount = ls_itemdata-net_amount.
 er_entity-gross_amount_ext = ls_itemdata-gross_amount_ext.
 er_entity-gross_amount = ls_itemdata-gross_amount.
 er_entity-currency_code = ls_itemdata-currency_code.
 er_entity-note = ls_itemdata-note.
 er_entity-product_id = ls_itemdata-product_id.
 er_entity-so_item_pos = ls_itemdata-so_item_pos.
 er_entity-so_id = ls_itemdata-so_id.
  endmethod.