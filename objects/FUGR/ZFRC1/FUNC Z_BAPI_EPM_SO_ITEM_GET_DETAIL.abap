FUNCTION z_bapi_epm_so_item_get_detail.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(SO_ID) TYPE  SNWD_SO_ID
*"     VALUE(SO_ITEM_POS) TYPE  SNWD_SO_ITEM_POS
*"  EXPORTING
*"     VALUE(HEADERDATA) TYPE  BAPI_EPM_SO_HEADER
*"  TABLES
*"      ITEMDATA STRUCTURE  BAPI_EPM_SO_ITEM OPTIONAL
*"      RETURN STRUCTURE  BAPIRET2 OPTIONAL
*"----------------------------------------------------------------------

  DATA: ls_so_id    TYPE bapi_epm_so_id,
        lt_itemdata TYPE STANDARD TABLE OF bapi_epm_so_item,
        ls_return   TYPE bapiret2..

  ls_so_id-so_id = so_id.

  CALL FUNCTION 'BAPI_EPM_SO_GET_DETAIL'
    EXPORTING
      so_id    = ls_so_id
*    IMPORTING
*     headerdata =
    TABLES
      itemdata = lt_itemdata
      return   = return.

  CHECK return[] IS INITIAL.

  ASSIGN lt_itemdata[ so_item_pos = so_item_pos ] TO FIELD-SYMBOL(<fs_itemdata>).

  IF <fs_itemdata> IS ASSIGNED.

    APPEND CORRESPONDING #( <fs_itemdata>  ) TO itemdata.

  ELSE.

    CALL FUNCTION 'BALW_BAPIRETURN_GET2'
      EXPORTING
        type   = 'E'
        cl     = 'SEPM_BOR_MESSAGES'
        number = '003'
        par1   = 'Item does not exist'
      IMPORTING
        return = ls_return.
    APPEND ls_return TO return.

  ENDIF.

ENDFUNCTION.