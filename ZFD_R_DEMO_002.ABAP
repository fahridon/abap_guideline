*&---------------------------------------------------------------------*
*& Report ZFD_R_DEMO_002
*&---------------------------------------------------------------------*
*& OO ALV : cl_gui_alv_grid
*& Data: SFLIGHT
*& Events: data_changed, onf4
*& Field Cataalog: LVC_FIELDCATALOG_MERGE
*& FM: F4_DATE - Holiday Calendar
*&---------------------------------------------------------------------*
REPORT zfd_r_demo_002.

INCLUDE: zfd_r_demo_002_top,
         zfd_r_demo_002_cls,
         zfd_r_demo_002_mdl.

START-OF-SELECTION.

  CREATE OBJECT go_main.

  go_main->start_screen( ).
