FUNCTION z_bapi_epm_so_item_create.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(SO_ID) TYPE  SNWD_SO_ID
*"     VALUE(SOITEMDATA) TYPE  BAPI_EPM_SO_ITEM
*"     VALUE(SOITEMDATAX) TYPE  BAPI_EPM_SO_ITEMX
*"     VALUE(PERSIST_TO_DB) TYPE  BAPI_EPM_BOOLEAN DEFAULT ABAP_TRUE
*"  EXPORTING
*"     VALUE(SO_ITEM_POS) TYPE  SNWD_SO_ITEM_POS
*"  TABLES
*"      RETURN STRUCTURE  BAPIRET2 OPTIONAL
*"----------------------------------------------------------------------
  DATA: ls_so_id        TYPE bapi_epm_so_id,
        lt_soitemdata   TYPE STANDARD TABLE OF bapi_epm_so_item,
        lt_soitemdatax  TYPE STANDARD TABLE OF bapi_epm_so_itemx,
        ls_itemdata_new TYPE bapi_epm_so_item,
        lt_itemdata_new TYPE STANDARD TABLE OF bapi_epm_so_item.

  ls_so_id-so_id = so_id.

  APPEND soitemdata TO lt_soitemdata.
  APPEND soitemdatax TO lt_soitemdatax.
  CALL FUNCTION 'BAPI_EPM_SO_CHANGE'
    EXPORTING
      so_id         = ls_so_id
      persist_to_db = persist_to_db
    TABLES
      soitemdata    = lt_soitemdata
      soitemdatax   = lt_soitemdatax
      return        = return.

  CHECK return[] IS INITIAL.
  CALL FUNCTION 'BAPI_EPM_SO_GET_DETAIL'
    EXPORTING
      so_id    = ls_so_id
    TABLES
      itemdata = lt_itemdata_new.

  SORT lt_itemdata_new BY so_item_pos DESCENDING.

  READ TABLE lt_itemdata_new INTO ls_itemdata_new INDEX 1.

  so_item_pos = ls_itemdata_new-so_item_pos.

ENDFUNCTION.