class ZCL_ZRFC1_MPC definition
  public
  inheriting from /IWBEP/CL_MGW_PUSH_ABS_MODEL
  create public .

public section.

  types:
     TS_SALESORDERHEADER type BAPI_EPM_SO_HEADER .
  types:
TT_SALESORDERHEADER type standard table of TS_SALESORDERHEADER .
  types:
   begin of ts_text_element,
      artifact_name  type c length 40,       " technical name
      artifact_type  type c length 4,
      parent_artifact_name type c length 40, " technical name
      parent_artifact_type type c length 4,
      text_symbol    type textpoolky,
   end of ts_text_element .
  types:
         tt_text_elements type standard table of ts_text_element with key text_symbol .
  types:
     TS_SALESORDERLINEITEM type BAPI_EPM_SO_ITEM .
  types:
TT_SALESORDERLINEITEM type standard table of TS_SALESORDERLINEITEM .

  constants GC_SALESORDERHEADER type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'SalesOrderHeader' ##NO_TEXT.
  constants GC_SALESORDERLINEITEM type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'SalesOrderLineItem' ##NO_TEXT.

  methods LOAD_TEXT_ELEMENTS
  final
    returning
      value(RT_TEXT_ELEMENTS) type TT_TEXT_ELEMENTS
    raising
      /IWBEP/CX_MGW_MED_EXCEPTION .

  methods DEFINE
    redefinition .
  methods GET_LAST_MODIFIED
    redefinition .