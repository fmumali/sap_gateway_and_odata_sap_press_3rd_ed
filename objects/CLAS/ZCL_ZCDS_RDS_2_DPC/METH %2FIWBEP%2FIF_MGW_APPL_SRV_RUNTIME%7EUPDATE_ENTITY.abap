  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~UPDATE_ENTITY.
*&----------------------------------------------------------------------------------------------*
*&  Include           /IWBEP/DPC_TEMP_UPD_ENTITY_BASE
*&* This class has been generated on 18.08.2024 20:46:59 in client 001
*&*
*&*       WARNING--> NEVER MODIFY THIS CLASS <--WARNING
*&*   If you want to change the DPC implementation, use the
*&*   generated methods inside the DPC provider subclass - ZCL_ZCDS_RDS_2_DPC_EXT
*&-----------------------------------------------------------------------------------------------*

 DATA zc_businesspartn_update_entity TYPE zcl_zcds_rds_2_mpc=>ts_zc_businesspartner_examplet.
 DATA zc_contacts_exam_update_entity TYPE zcl_zcds_rds_2_mpc=>ts_zc_contacts_exampletype.
 DATA lv_entityset_name TYPE string.
 DATA lr_entity TYPE REF TO data. "#EC NEEDED

lv_entityset_name = io_tech_request_context->get_entity_set_name( ).

CASE lv_entityset_name.
*-------------------------------------------------------------------------*
*             EntitySet -  ZC_BusinessPartner_Example
*-------------------------------------------------------------------------*
      WHEN 'ZC_BusinessPartner_Example'.
*     Call the entity set generated method
          zc_businesspartn_update_entity(
               EXPORTING iv_entity_name     = iv_entity_name
                         iv_entity_set_name = iv_entity_set_name
                         iv_source_name     = iv_source_name
                         io_data_provider   = io_data_provider
                         it_key_tab         = it_key_tab
                         it_navigation_path = it_navigation_path
                         io_tech_request_context = io_tech_request_context
             	 IMPORTING er_entity          = zc_businesspartn_update_entity
          ).
       IF zc_businesspartn_update_entity IS NOT INITIAL.
*     Send specific entity data to the caller interface
          copy_data_to_ref(
            EXPORTING
              is_data = zc_businesspartn_update_entity
            CHANGING
              cr_data = er_entity
          ).
        ELSE.
*         In case of initial values - unbind the entity reference
          er_entity = lr_entity.
        ENDIF.
*-------------------------------------------------------------------------*
*             EntitySet -  ZC_Contacts_Example
*-------------------------------------------------------------------------*
      WHEN 'ZC_Contacts_Example'.
*     Call the entity set generated method
          zc_contacts_exam_update_entity(
               EXPORTING iv_entity_name     = iv_entity_name
                         iv_entity_set_name = iv_entity_set_name
                         iv_source_name     = iv_source_name
                         io_data_provider   = io_data_provider
                         it_key_tab         = it_key_tab
                         it_navigation_path = it_navigation_path
                         io_tech_request_context = io_tech_request_context
             	 IMPORTING er_entity          = zc_contacts_exam_update_entity
          ).
       IF zc_contacts_exam_update_entity IS NOT INITIAL.
*     Send specific entity data to the caller interface
          copy_data_to_ref(
            EXPORTING
              is_data = zc_contacts_exam_update_entity
            CHANGING
              cr_data = er_entity
          ).
        ELSE.
*         In case of initial values - unbind the entity reference
          er_entity = lr_entity.
        ENDIF.
      WHEN OTHERS.
        super->/iwbep/if_mgw_appl_srv_runtime~update_entity(
           EXPORTING
             iv_entity_name = iv_entity_name
             iv_entity_set_name = iv_entity_set_name
             iv_source_name = iv_source_name
             io_data_provider   = io_data_provider
             it_key_tab = it_key_tab
             it_navigation_path = it_navigation_path
          IMPORTING
            er_entity = er_entity
    ).
 ENDCASE.
  endmethod.