*&---------------------------------------------------------------------*
*& Include zfd_r_oop_mvc_report_cls
*&---------------------------------------------------------------------*

*create selection screen class
CLASS cl_sel DEFINITION FINAL .
  PUBLIC SECTION .
    TYPES: t_connid  TYPE RANGE OF s_conn_id  .
    DATA : s_connid TYPE t_connid .
    DATA : s_carrid TYPE s_carr_id  .
* Method to get the screen data
    METHODS : get_screen IMPORTING lp_carrid TYPE s_carr_id
                                   ls_connid TYPE t_connid .
ENDCLASS .                    "CL_SEL DEFINITION
*&---------------------------------------------------------------------*
*&       CLASS (IMPLEMENTATION)  SEL
*&---------------------------------------------------------------------*
*        TEXT
*----------------------------------------------------------------------*
CLASS cl_sel IMPLEMENTATION.
*  Method implementation for screen
  METHOD get_screen .
    me->s_carrid = lp_carrid.
    me->s_connid = ls_connid[] .
  ENDMETHOD .                    "GET_SCREEN
ENDCLASS.               "SEL
*----------------------------------------------------------------------*
*       CLASS CL_FETCH DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS cl_fetch DEFINITION .
  PUBLIC SECTION.
    DATA : it_sflight TYPE STANDARD TABLE OF sflight .
    DATA : sel_obj TYPE REF TO cl_sel .
*  GET_SEL method to get the object of screen class
    METHODS : get_sel.
*  After getting selection screen call method Fetch data
    METHODS : fetch_data .
ENDCLASS .                    "CL_FETCH DEFINITION

*----------------------------------------------------------------------*
*       CLASS CL_FETCH IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS cl_fetch IMPLEMENTATION .
  METHOD get_sel.
* create object of selection class
    CREATE OBJECT sel_obj.
  ENDMETHOD.
  METHOD fetch_data .
* Fetch the data from selection screen
    IF sel_obj IS BOUND .
      SELECT * FROM sflight INTO TABLE me->it_sflight UP TO 10 ROWS
      WHERE connid IN me->sel_obj->s_connid
      AND carrid EQ me->sel_obj->s_carrid .
    ENDIF .
  ENDMETHOD .                    "FETCH_DATA
ENDCLASS .                    "CL_FETCH IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS CL_CONTROLLER DEFINITION
*----------------------------------------------------------------------*
* controller class to get the data from MODEL
*----------------------------------------------------------------------*
CLASS cl_controller DEFINITION.
  PUBLIC SECTION.
    DATA    : obj_model TYPE REF TO cl_fetch .
*   GET_OBJECT method to get object of model
    METHODS : get_object IMPORTING gen_name TYPE char30.
ENDCLASS .                    "CL_CONTROLLER DEFINITION

*----------------------------------------------------------------------*
*       CLASS CL_CONTROLLER IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS cl_controller IMPLEMENTATION .
  METHOD get_object.
    DATA : lv_object TYPE REF TO object.
*  GEN_NAME is of type CHAR30
    CREATE OBJECT lv_object TYPE (gen_name).
    IF sy-subrc EQ 0.
      obj_model ?= lv_object .
    ENDIF.
  ENDMETHOD .                    "GET_OBJECT
ENDCLASS .                    "CL_CONTROLLER IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS CL_ALV DEFINITION
*----------------------------------------------------------------------*
*CL_ALV class our VIEW
*----------------------------------------------------------------------*
CLASS cl_alv DEFINITION .
  PUBLIC SECTION .
    METHODS : display_alv IMPORTING con_obj TYPE REF TO cl_controller.
ENDCLASS .                    "CL_ALV DEFINITION

*----------------------------------------------------------------------*
*       CLASS CL_ALV IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS cl_alv IMPLEMENTATION.
  METHOD display_alv .
    DATA: lx_msg TYPE REF TO cx_salv_msg.
    DATA: o_alv TYPE REF TO cl_salv_table.
    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = o_alv
          CHANGING
            t_table      =  con_obj->obj_model->it_sflight ).
      CATCH cx_salv_msg INTO lx_msg.
    ENDTRY.
    o_alv->display( ).

  ENDMETHOD.                    "DISPLAY_ALV
ENDCLASS.                    "CL_ALV IMPLEMENTATION
