  method SALESORDERHEADER_DELETE_ENTITY.
*-------------------------------------------------------------
*  Data declaration
*-------------------------------------------------------------
 DATA so_id TYPE zif_bapi_epm_so_delete=>bapi_epm_so_id.
 DATA return  TYPE zif_bapi_epm_so_delete=>__bapiret2.
 DATA ls_return  TYPE LINE OF zif_bapi_epm_so_delete=>__bapiret2.
 DATA lv_rfc_name TYPE tfdir-funcname.
 DATA lv_destination TYPE rfcdest.
 DATA lv_subrc TYPE syst-subrc.
 DATA lv_exc_msg TYPE /iwbep/mgw_bop_rfc_excep_text.
 DATA lx_root TYPE REF TO cx_root.
 DATA ls_converted_keys TYPE zcl_zrfc1_mpc=>ts_salesorderheader.
 DATA lv_source_entity_set_name TYPE string.
 DATA lo_dp_facade TYPE REF TO /iwbep/if_mgw_dp_facade.

*-------------------------------------------------------------
*  Map the runtime request to the RFC - Only mapped attributes
*-------------------------------------------------------------
* Get all input information from the technical request context object
* Since DPC works with internal property names and runtime API interface holds external property names
* the process needs to get the all needed input information from the technical request context object
* Get key table information
 io_tech_request_context->get_converted_keys(
   IMPORTING
     es_key_values = ls_converted_keys ).

* Maps key fields to function module parameters

 so_id-so_id = ls_converted_keys-so_id.
* Get RFC destination
 lo_dp_facade = /iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).
 lv_destination = /iwbep/cl_sb_gen_dpc_rt_util=>get_rfc_destination( io_dp_facade = lo_dp_facade ).

*-------------------------------------------------------------
*  Call RFC function module
*-------------------------------------------------------------
 lv_rfc_name = 'BAPI_EPM_SO_DELETE'.

 IF lv_destination IS INITIAL OR lv_destination EQ 'NONE'.

   TRY.
       CALL FUNCTION lv_rfc_name
         EXPORTING
           so_id          = so_id
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