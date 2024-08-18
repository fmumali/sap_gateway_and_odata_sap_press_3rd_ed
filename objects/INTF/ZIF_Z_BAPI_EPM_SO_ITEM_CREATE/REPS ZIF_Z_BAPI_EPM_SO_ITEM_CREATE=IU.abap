interface ZIF_Z_BAPI_EPM_SO_ITEM_CREATE
  public .


  types:
    SNWD_SO_ITEM_POS type C length 000010 .
  types:
    SNWD_BOOL type C length 000001 .
  types:
    begin of BAPI_EPM_BOOLEAN,
      VALUE type SNWD_BOOL,
    end of BAPI_EPM_BOOLEAN .
  types:
    SNWD_SO_ID type C length 000010 .
  types:
    SNWD_PRODUCT_ID type C length 000010 .
  types:
    SNWD_DESC type C length 000255 .
  types:
    SNWD_CURR_CODE type C length 000005 .
  types:
    SNWD_TTL_GROSS_AMOUNT type P length 8  decimals 000002 .
  types:
    SEPM_AMOUNT_BAPI type P length 12  decimals 000004 .
  types:
    SNWD_TTL_NET_AMOUNT type P length 8  decimals 000002 .
  types:
    SNWD_TTL_TAX_AMOUNT type P length 8  decimals 000002 .
  types:
    TIMESTAMPL type P length 11  decimals 000007 .
  types:
    SNWD_QUANTITY type P length 7  decimals 000003 .
  types:
    SNWD_QUANTITY_UNIT type C length 000003 .
  types:
    begin of BAPI_EPM_SO_ITEM,
      SO_ID type SNWD_SO_ID,
      SO_ITEM_POS type SNWD_SO_ITEM_POS,
      PRODUCT_ID type SNWD_PRODUCT_ID,
      NOTE type SNWD_DESC,
      CURRENCY_CODE type SNWD_CURR_CODE,
      GROSS_AMOUNT type SNWD_TTL_GROSS_AMOUNT,
      GROSS_AMOUNT_EXT type SEPM_AMOUNT_BAPI,
      NET_AMOUNT type SNWD_TTL_NET_AMOUNT,
      NET_AMOUNT_EXT type SEPM_AMOUNT_BAPI,
      TAX_AMOUNT type SNWD_TTL_TAX_AMOUNT,
      TAX_AMOUNT_EXT type SEPM_AMOUNT_BAPI,
      DELIVERY_DATE type TIMESTAMPL,
      QUANTITY type SNWD_QUANTITY,
      QUANTITY_UNIT type SNWD_QUANTITY_UNIT,
    end of BAPI_EPM_SO_ITEM .
  types:
    BAPIUPDATE type C length 000001 .
  types:
    SEPM_ACTION_CODE_BAPI type C length 000001 .
  types:
    begin of BAPI_EPM_SO_ITEMX,
      SO_ID type SNWD_SO_ID,
      SO_ITEM_POS type SNWD_SO_ITEM_POS,
      PRODUCT_ID type SNWD_PRODUCT_ID,
      DELIVERY_DATE type TIMESTAMPL,
      NOTE type BAPIUPDATE,
      CURRENCY_CODE type BAPIUPDATE,
      GROSS_AMOUNT type BAPIUPDATE,
      NET_AMOUNT type BAPIUPDATE,
      TAX_AMOUNT type BAPIUPDATE,
      QUANTITY type BAPIUPDATE,
      QUANTITY_UNIT type BAPIUPDATE,
      ACTIONCODE type SEPM_ACTION_CODE_BAPI,
    end of BAPI_EPM_SO_ITEMX .
  types:
    BAPI_MTYPE type C length 000001 .
  types:
    SYMSGID type C length 000020 .
  types:
    SYMSGNO type N length 000003 .
  types:
    BAPI_MSG type C length 000220 .
  types:
    BALOGNR type C length 000020 .
  types:
    BALMNR type N length 000006 .
  types:
    SYMSGV type C length 000050 .
  types:
    BAPI_PARAM type C length 000032 .
  types:
    BAPI_FLD type C length 000030 .
  types:
    BAPILOGSYS type C length 000010 .
  types:
    begin of BAPIRET2,
      TYPE type BAPI_MTYPE,
      ID type SYMSGID,
      NUMBER type SYMSGNO,
      MESSAGE type BAPI_MSG,
      LOG_NO type BALOGNR,
      LOG_MSG_NO type BALMNR,
      MESSAGE_V1 type SYMSGV,
      MESSAGE_V2 type SYMSGV,
      MESSAGE_V3 type SYMSGV,
      MESSAGE_V4 type SYMSGV,
      PARAMETER type BAPI_PARAM,
      ROW type INT4,
      FIELD type BAPI_FLD,
      SYSTEM type BAPILOGSYS,
    end of BAPIRET2 .
  types:
    __BAPIRET2                     type standard table of BAPIRET2                       with non-unique default key .
endinterface.