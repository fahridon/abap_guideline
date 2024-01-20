*&---------------------------------------------------------------------*
*& Report zst2calc
*&---------------------------------------------------------------------*
*& Demo calculation program
*&---------------------------------------------------------------------*
REPORT zst2calc.

***********************************************************************
* Selection screen definition
***********************************************************************
SELECTION-SCREEN BEGIN OF BLOCK main WITH FRAME.
  PARAMETERS:
    p_input1 TYPE i,
    p_input2 TYPE i.
SELECTION-SCREEN END OF BLOCK main.

***********************************************************************
* Exception class definition
***********************************************************************
CLASS lcx_error DEFINITION
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES:
      if_t100_message.

    CONSTANTS:
      exception_lcx_error TYPE string
        VALUE 'LCX_ERROR'.

*   Add additional exception type texts and objects

    CONSTANTS:
      BEGIN OF lcx_error,
*     --> Default exception type
        msgid TYPE symsgid VALUE 'ZST2_GENERAL',
        msgno TYPE symsgno VALUE '000',
        attr1 TYPE scx_attrname VALUE 'EXCEPTION_LCX_ERROR',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF lcx_error.

    METHODS:
      constructor
        IMPORTING
          textid   LIKE if_t100_message=>t100key OPTIONAL
          previous LIKE previous OPTIONAL.

ENDCLASS.


***********************************************************************
* Startup class definition
***********************************************************************
CLASS lcl_start DEFINITION.

  PUBLIC SECTION.

    CONSTANTS:
      mc_error  TYPE bapi_mtype VALUE 'E',
      mc_status TYPE bapi_mtype VALUE 'S'.

    CLASS-DATA:
*     Generic error object
      mo_error TYPE REF TO cx_root.

    CLASS-METHODS:
      run
        RAISING lcx_error.

ENDCLASS.


***********************************************************************
* Main processing class definition
***********************************************************************
CLASS lcl_main DEFINITION.

  PUBLIC SECTION.

* Uncomment for one-time INITIALIZATION routines
*    CLASS-METHODS:
*      class_constructor.

    METHODS:
      constructor
        IMPORTING
                  iv_input1 TYPE i
                  iv_input2 TYPE i
        RAISING   lcx_error.

  PRIVATE SECTION.
*   Define program data attributes as class members
    DATA: mv_result TYPE i.

    METHODS:
* add two values and return the result
      add_values
        IMPORTING
                  iv_input1        TYPE i
                  iv_input2        TYPE i
        RETURNING VALUE(rv_result) TYPE i,

* display result in popup
      display_result
        IMPORTING
          iv_result TYPE i.

ENDCLASS.


***********************************************************************
* Program starts here
***********************************************************************
START-OF-SELECTION.
  TRY.
      lcl_start=>run( ).
    CATCH cx_root INTO lcl_start=>mo_error.
      MESSAGE lcl_start=>mo_error TYPE lcl_start=>mc_status
                                  DISPLAY LIKE  lcl_start=>mc_error.
  ENDTRY.


***********************************************************************
* Exception class implementation
***********************************************************************
CLASS lcx_error IMPLEMENTATION.

  METHOD constructor.

    CALL METHOD super->constructor
      EXPORTING
        previous = previous.

    CLEAR me->textid.

    IF textid IS INITIAL.
*     Raise default exception type
      if_t100_message~t100key = lcx_error.
    ELSE.
      if_t100_message~t100key = textid.

*   Transfer additional exception texts here

    ENDIF.

  ENDMETHOD.

ENDCLASS.


***********************************************************************
* Startup class implementation
***********************************************************************
CLASS lcl_start IMPLEMENTATION.

  METHOD run.

*   Extend call to include any selection screen parameters
    DATA(lo_main) = NEW lcl_main( iv_input1 = p_input1
                                  iv_input2 = p_input2 ).

  ENDMETHOD.

ENDCLASS.


***********************************************************************
* Main processing class implementation
***********************************************************************
CLASS lcl_main IMPLEMENTATION.

* Uncomment for one-time INITIALIZATION routines
*  METHOD class_constructor.
*
**   Add code for implementation
*
*  ENDMETHOD.

  METHOD constructor.

*   Add code for implementation
    mv_result = add_values( iv_input1 = iv_input1
                            iv_input2 = iv_input2 ).

    display_result( mv_result ).

  ENDMETHOD.

  METHOD add_values.
    rv_result = iv_input1 + iv_input2.
  ENDMETHOD.

  METHOD display_result.
    DATA: lv_text   TYPE text40,
          lv_string TYPE string.

    WRITE iv_result TO lv_text LEFT-JUSTIFIED.

    lv_string = TEXT-t01 && || && lv_text.
*          --> Calculation result =
    CALL FUNCTION 'POPUP_TO_DISPLAY_STRING'
      EXPORTING
        iv_title  = 'baslık'
        iv_string = lv_string
*       iv_starting_col = 1
*       iv_starting_row = 1
      .



  ENDMETHOD..

ENDCLASS.
