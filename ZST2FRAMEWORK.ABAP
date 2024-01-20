*&---------------------------------------------------------------------*
*& Report ZST2FRAMEWORK
*&---------------------------------------------------------------------*
*& Generic report program framework
*&---------------------------------------------------------------------*
REPORT zst2framework.

***********************************************************************
* Selection screen definition
***********************************************************************


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
        RAISING lcx_error.

  PRIVATE SECTION.
*   Define program data attributes as class members

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
    DATA(lo_main) = NEW lcl_main( ).

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

  ENDMETHOD.

ENDCLASS.
