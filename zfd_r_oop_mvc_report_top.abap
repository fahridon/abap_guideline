*&---------------------------------------------------------------------*
*& Include zfd_r_oop_mvc_report_top
*&---------------------------------------------------------------------*

DATA : lv_connid TYPE sflight-connid  .

*Create selection screen
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-000.
  PARAMETERS : p_carrid TYPE sflight-carrid OBLIGATORY.
  SELECT-OPTIONS : s_connid FOR lv_connid .
SELECTION-SCREEN END OF BLOCK b1 .
