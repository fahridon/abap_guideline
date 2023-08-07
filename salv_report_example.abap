*&---------------------------------------------------------------------*
*& Report ZFD_R_SALV_SBOOK
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfd_r_salv_sbook.

DATA: gt_book TYPE TABLE OF sbook,
      go_salv TYPE REF TO cl_salv_table.

START-OF-SELECTION.

  "get data for itab
  SELECT * UP TO 25 ROWS INTO TABLE gt_book FROM sbook.

  "create salv object for itab
  cl_salv_table=>factory(
    IMPORTING
      r_salv_table   =   go_salv         " Basis Class Simple ALV Tables
    CHANGING
      t_table        = gt_book ).

  "set alv reaport header and lines zebra pattern
  DATA lo_display TYPE REF TO cl_salv_display_settings.
  lo_display = go_salv->get_display_settings( ).
  lo_display->set_list_header( value = 'SALV Örnek Rapor ' ).
  lo_display->set_striped_pattern( value = abap_true ).

  "set alv columns weith
  DATA lo_cols TYPE REF TO cl_salv_columns.
  lo_cols = go_salv->get_columns( ).
  lo_cols->set_optimize( value = abap_true ).

  "set alc column header and visibility
  DATA lo_col TYPE REF TO cl_salv_column.
  TRY.
      lo_col = lo_cols->get_column( columnname = 'INVOICE' ).
      lo_col->set_long_text('Uzaun Başlık Fatur').
      lo_col->set_medium_text('Ort.BaşFatur').
      lo_col->set_short_text('K.Fatur').
      lo_col = lo_cols->get_column( columnname = 'MANDT' ).
      lo_col->set_visible( value = abap_false ).
    CATCH cx_salv_not_found.

  ENDTRY.


  " set alv button functions
  DATA lo_func TYPE REF TO cl_salv_functions.
  lo_func = go_salv->get_functions( ).
  lo_func->set_all( abap_true ).

  "set alv header and follow texts
  DATA: lo_grid  TYPE REF TO cl_salv_form_layout_grid,
        lo_label TYPE REF TO cl_salv_form_label,
        lo_flow  TYPE REF TO cl_salv_form_layout_flow.
  CREATE OBJECT lo_grid.
  lo_label = lo_grid->create_label( row = 1 column = 1 ).
  lo_label->set_text( 'SALV Metin Başlığı' ).
  lo_flow = lo_grid->create_flow( row = 2 column = 1 ).
  lo_flow->create_text( EXPORTING text = 'SALV açıklama metni.....!' ).
  go_salv->set_top_of_list( value = lo_grid ).

  "show alv
  go_salv->display( ).
