  METHOD /bobf/if_frw_determination~execute.

    DATA: lt_data              TYPE ztiinventory_tp,
          lv_next_inventory_id TYPE zinventory_record_id.

    io_read->retrieve(
      EXPORTING
        iv_node       = is_ctx-node_key
        it_key        = it_key
      IMPORTING
        eo_message    = eo_message
        et_data       = lt_data
        et_failed_key = et_failed_key
    ).

    LOOP AT lt_data REFERENCE INTO DATA(lr_data) WHERE inventory_id IS INITIAL.

      CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          nr_range_nr             = '1'
          object                  = 'ZINVENTORY'
        IMPORTING
          number                  = lv_next_inventory_id
        EXCEPTIONS
          interval_not_found      = 1
          number_range_not_intern = 2
          object_not_found        = 3
          quantity_is_0           = 4
          quantity_is_not_1       = 5
          interval_overflow       = 6
          buffer_overflow         = 7
          OTHERS                  = 8.

      IF sy-subrc EQ 0.

        lr_data->inventory_id = lv_next_inventory_id.

        GET TIME STAMP FIELD lr_data->created_at.

        io_modify->update(
          iv_node           = is_ctx-node_key
          iv_key            = lr_data->key
          is_data           = lr_data
          it_changed_fields = VALUE #( ( zif_i_inventory_tp_c=>sc_node_attribute-zi_inventory_tp-inventory_id )
                                       ( zif_i_inventory_tp_c=>sc_node_attribute-zi_inventory_tp-created_at ) )
        ).

      ELSE.

        IF eo_message IS NOT BOUND.
          eo_message = /bobf/cl_frw_message_factory=>create_container( ).
        ENDIF.
        eo_message->add_message(
          is_msg  = VALUE #(  msgid = 'ZINVENTORY'
                              msgno = 001"Unable to fetch next Inventory ID
                              msgty = /bobf/cm_frw=>co_severity_error   )
          iv_node = is_ctx-node_key
          iv_key  = lr_data->key
        ).
        APPEND VALUE #( key = lr_data->key ) TO et_failed_key.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.