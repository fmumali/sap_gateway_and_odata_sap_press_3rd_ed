  method IF_SADL_GW_DPC_UTIL~GET_DPC.
    TYPES ty_zi_businesspartner_exam_1 TYPE zi_businesspartner_example ##NEEDED. " reference for where-used list

    DATA(lv_sadl_xml) =
               |<?xml version="1.0" encoding="utf-16"?>| &
               |<sadl:definition xmlns:sadl="http://sap.com/sap.nw.f.sadl" syntaxVersion="V2" >| &
               | <sadl:dataSource type="CDS" name="BusinessPartnerSet" binding="ZI_BUSINESSPARTNER_EXAMPLE" />| &
               |<sadl:resultSet>| &
               |<sadl:structure name="BusinessPartnerSet" dataSource="BusinessPartnerSet" maxEditMode="RO" >| &
               | <sadl:query name="EntitySetDefault">| &
               | </sadl:query>| &
               | <sadl:attribute name="BUSINESSPARTNERID" binding="BUSINESSPARTNERID" isKey="TRUE" />| &
               | <sadl:attribute name="CITY" binding="CITY" isKey="FALSE" />| &
               | <sadl:attribute name="COMPANYNAME" binding="COMPANYNAME" isKey="FALSE" />| &
               | <sadl:attribute name="COUNTRYID" binding="COUNTRYID" isKey="FALSE" />| &
               | <sadl:attribute name="LEGALFORM" binding="LEGALFORM" isKey="FALSE" />| &
               |</sadl:structure>| &
               |</sadl:resultSet>| &
               |</sadl:definition>| .
    ro_dpc = cl_sadl_gw_dpc_factory=>create_for_sadl( iv_sadl_xml          = lv_sadl_xml
                                                      iv_timestamp         = 20240818190226
                                                      iv_uuid              = 'ZCDS_MDS'
                                                      io_query_control     = me
                                                      io_extension_control = me
                                                      io_context           = me->mo_context ).
  endmethod.