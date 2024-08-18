  method IF_SADL_GW_MODEL_EXPOSURE_DATA~GET_MODEL_EXPOSURE.
    CONSTANTS: co_gen_timestamp TYPE timestamp VALUE '20240818204658'.
    DATA(lv_sadl_xml) =
               |<?xml version="1.0" encoding="utf-16"?>|  &
               |<sadl:definition xmlns:sadl="http://sap.com/sap.nw.f.sadl" syntaxVersion="" >|  &
               | <sadl:dataSource type="CDS" name="ZC_BUSINESSPARTNER_EXAMPLE" binding="ZC_BUSINESSPARTNER_EXAMPLE" />|  &
               | <sadl:dataSource type="CDS" name="ZC_CONTACTS_EXAMPLE" binding="ZC_CONTACTS_EXAMPLE" />|  &
               |<sadl:resultSet>|  &
               |<sadl:structure name="ZC_BusinessPartner_Example" dataSource="ZC_BUSINESSPARTNER_EXAMPLE" maxEditMode="RO" exposure="TRUE" >|  &
               | <sadl:query name="SADL_QUERY">|  &
               | </sadl:query>|  &
               | <sadl:association name="TO_CONTACTS" binding="_CONTACTS" target="ZC_Contacts_Example" cardinality="zeroToMany" />|  &
               |</sadl:structure>|  &
               |<sadl:structure name="ZC_Contacts_Example" dataSource="ZC_CONTACTS_EXAMPLE" maxEditMode="RO" exposure="TRUE" >|  &
               | <sadl:query name="SADL_QUERY">|  &
               | </sadl:query>|  &
               |</sadl:structure>|  &
               |</sadl:resultSet>|  &
               |</sadl:definition>| .

   ro_model_exposure = cl_sadl_gw_model_exposure=>get_exposure_xml( iv_uuid      = CONV #( 'ZCDS_RDS_2' )
                                                                    iv_timestamp = co_gen_timestamp
                                                                    iv_sadl_xml  = lv_sadl_xml ).
  endmethod.