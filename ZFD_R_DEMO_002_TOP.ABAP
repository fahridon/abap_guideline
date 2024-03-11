*&---------------------------------------------------------------------*
*& Include          ZFD_R_DEMO_002_TOP
*&---------------------------------------------------------------------*

CLASS lcl_class DEFINITION DEFERRED.

CLASS lcl_event_receiver DEFINITION DEFERRED.

DATA: go_main           TYPE REF TO lcl_class,
      go_grid           TYPE REF TO cl_gui_alv_grid,
      go_container      TYPE REF TO cl_gui_custom_container,

      gt_fcat           TYPE lvc_t_fcat,
      gs_fcat           TYPE lvc_s_fcat,
      gs_layout         TYPE lvc_s_layo,

      gt_alv_table      TYPE TABLE OF sflight,
      gs_alv_table      TYPE  sflight,

      go_event_receiver TYPE REF TO lcl_event_receiver.
