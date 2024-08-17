  METHOD define.

    DATA: lo_entity_type TYPE REF TO /iwbep/if_mgw_odata_entity_typ,
          lo_property
            TYPE REF TO /iwbep/if_mgw_odata_property.
    super->define( ).
    lo_entity_type = model->get_entity_type( 'SalesOrderHeader' ).
    lo_property = lo_entity_type->get_property( 'SoId' ).
    lo_property->disable_conversion( ).

  ENDMETHOD.