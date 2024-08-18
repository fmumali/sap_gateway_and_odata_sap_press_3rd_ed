  method IF_SADL_GW_DPC_UTIL~GET_DPC.
    TYPES ty_zi_businesspartner_exam_1 TYPE zi_businesspartner_example ##NEEDED. " reference for where-used list

    DATA(lv_sadl_xml) =
               |<?xml version="1.0" encoding="utf-16"?>| &
               |<sadl:definition xmlns:sadl="http://sap.com/sap.nw.f.sadl" syntaxVersion="" >| &
               | <sadl:dataSource type="CDS" name="ZI_BUSINESSPARTNER_EXAMPLE" binding="ZI_BUSINESSPARTNER_EXAMPLE" />| &
               | <sadl:dataSource type="CDS" name="ZI_CONTACTS_EXAMPLE" binding="ZI_CONTACTS_EXAMPLE" />| &
               |<sadl:resultSet>| &
               |<sadl:structure name="ZI_BusinessPartner_Example" dataSource="ZI_BUSINESSPARTNER_EXAMPLE" maxEditMode="RO" exposure="TRUE" >| &
               | <sadl:query name="SADL_QUERY">| &
               | </sadl:query>| &
               | <sadl:association name="TO_CONTACTS" binding="_CONTACTS" target="ZI_CONTACTS_EXAMPLE" cardinality="zeroToMany" />| &
               |</sadl:structure>| &
               |<sadl:structure name="ZI_CONTACTS_EXAMPLE" dataSource="ZI_CONTACTS_EXAMPLE" maxEditMode="RO" exposure="TRUE" >| &
               | <sadl:query name="SADL_QUERY">| &
               | </sadl:query>| &
               |</sadl:structure>| &
               |</sadl:resultSet>| &
               |</sadl:definition>| .
    ro_dpc = cl_sadl_gw_dpc_factory=>create_for_sadl( iv_sadl_xml  = lv_sadl_xml
                                                      iv_timestamp = 20240818194555
                                                      iv_uuid      = 'ZCDS_RDS'
                                                      io_context   = me->mo_context ).
  endmethod.