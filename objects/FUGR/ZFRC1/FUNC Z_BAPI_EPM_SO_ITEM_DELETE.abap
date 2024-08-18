FUNCTION z_bapi_epm_so_item_delete.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(SO_ID) TYPE  SNWD_SO_ID
*"     VALUE(SO_ITEM_POS) TYPE  SNWD_SO_ITEM_POS
*"     VALUE(PERSIST_TO_DB) TYPE  BAPI_EPM_BOOLEAN DEFAULT ABAP_TRUE
*"  TABLES
*"      RETURN STRUCTURE  BAPIRET2 OPTIONAL
*"----------------------------------------------------------------------
  DATA: ls_so_id     TYPE bapi_epm_so_id,
        ls_itemdata  TYPE bapi_epm_so_item,
        lt_itemdata  TYPE STANDARD TABLE OF bapi_epm_so_item,
        ls_itemdatax TYPE bapi_epm_so_itemx,
        lt_itemdatax TYPE STANDARD TABLE OF bapi_epm_so_itemx.


  CALL FUNCTION 'Z_BAPI_EPM_SO_ITEM_GET_DETAIL'
    EXPORTING
      so_id       = so_id
      so_item_pos = so_item_pos
    IMPORTING
      itemdata    = ls_itemdata
    TABLES
      return      = return.

  CHECK return[] IS INITIAL.
  APPEND ls_itemdata TO lt_itemdata.

  ls_itemdatax-so_id = so_id.
  ls_itemdatax-so_item_pos  = so_item_pos.
  ls_itemdatax-product_id   = ls_itemdata-product_id.
  ls_itemdatax-delivery_date = ls_itemdata-delivery_date.
  ls_itemdatax-actioncode   = 'D'.

  APPEND ls_itemdatax TO lt_itemdatax.
  ls_so_id-so_id = so_id.
  CALL FUNCTION 'BAPI_EPM_SO_CHANGE'
    EXPORTING
      so_id         = ls_so_id
*     SOHEADERDATA  =
*     SOHEADERDATAX =
      persist_to_db = persist_to_db
    TABLES
      soitemdata    = lt_itemdata
      soitemdatax   = lt_itemdatax
      return        = return.

ENDFUNCTION.