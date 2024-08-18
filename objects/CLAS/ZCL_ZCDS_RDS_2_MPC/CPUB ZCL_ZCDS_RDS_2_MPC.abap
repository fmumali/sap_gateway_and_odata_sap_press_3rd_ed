class ZCL_ZCDS_RDS_2_MPC definition
  public
  inheriting from /IWBEP/CL_MGW_PUSH_ABS_MODEL
  create public .

public section.

  interfaces IF_SADL_GW_MODEL_EXPOSURE_DATA .

  types:
    begin of TS_ZC_BUSINESSPARTNER_EXAMPLET.
      include type ZC_BUSINESSPARTNER_EXAMPLE.
  types:
    end of TS_ZC_BUSINESSPARTNER_EXAMPLET .
  types:
   TT_ZC_BUSINESSPARTNER_EXAMPLET type standard table of TS_ZC_BUSINESSPARTNER_EXAMPLET .
  types:
    begin of TS_ZC_CONTACTS_EXAMPLETYPE.
      include type ZC_CONTACTS_EXAMPLE.
  types:
    end of TS_ZC_CONTACTS_EXAMPLETYPE .
  types:
   TT_ZC_CONTACTS_EXAMPLETYPE type standard table of TS_ZC_CONTACTS_EXAMPLETYPE .

  constants GC_ZC_BUSINESSPARTNER_EXAMPLET type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'ZC_BusinessPartner_ExampleType' ##NO_TEXT.
  constants GC_ZC_CONTACTS_EXAMPLETYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'ZC_Contacts_ExampleType' ##NO_TEXT.

  methods DEFINE
    redefinition .
  methods GET_LAST_MODIFIED
    redefinition .