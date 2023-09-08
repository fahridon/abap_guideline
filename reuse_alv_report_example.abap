*&---------------------------------------------------------------------*
*& Report ZFD_R_REUSE_ALV
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfd_r_reuse_alv.
DATA : lt_scarr  TYPE TABLE OF scarr,
       lt_fcat   TYPE slis_t_fieldcat_alv,
       ls_layout TYPE slis_layout_alv,
       lt_events TYPE slis_t_event,
       ls_events TYPE slis_alv_event.


INITIALIZATION.

START-OF-SELECTION.

  " get data
  SELECT * INTO TABLE lt_scarr FROM scarr.

  " create field catalog
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
*     I_PROGRAM_NAME         =
*     I_INTERNAL_TABNAME     =
      i_structure_name       = 'SCARR'
*     I_CLIENT_NEVER_DISPLAY = 'X'
*     I_INCLNAME             =
*     I_BYPASSING_BUFFER     =
*     I_BUFFER_ACTIVE        =
    CHANGING
      ct_fieldcat            = lt_fcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


  " show ALV
  ls_layout-colwidth_optimize = abap_true.

  ls_events-name = slis_ev_top_of_page.
  ls_events-form = 'FRM_ALV_HEADER'.
  APPEND ls_events TO lt_events.

  ls_events-name = slis_ev_end_of_page.
  ls_events-form = 'FRM_ALV_FOOTER'.
  APPEND ls_events TO lt_events.

  ls_events-name = slis_ev_pf_status_set.
  ls_events-form = 'FRM_ZSTATUS'.
  APPEND ls_events TO lt_events.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK       = ' '
*     I_BYPASSING_BUFFER      = ' '
*     I_BUFFER_ACTIVE         = ' '
      i_callback_program      = sy-repid
*     i_callback_pf_status_set = 'FRM_ZSTATUS'
      i_callback_user_command = 'FRM_USR_CMND'
*     i_callback_top_of_page  = 'FRM_TOP_ALV_PAGE'
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME        =
*     I_BACKGROUND_ID         = ' '
*     I_GRID_TITLE            =
*     I_GRID_SETTINGS         =
      is_layout               = ls_layout
      it_fieldcat             = lt_fcat
*     IT_EXCLUDING            =
*     IT_SPECIAL_GROUPS       =
*     IT_SORT                 =
*     IT_FILTER               =
*     IS_SEL_HIDE             =
*     I_DEFAULT               = 'X'
*     I_SAVE                  = ' '
*     IS_VARIANT              =
      it_events               = lt_events
*     IT_EVENT_EXIT           =
*     IS_PRINT                =
*     IS_REPREP_ID            =
*     I_SCREEN_START_COLUMN   = 0
*     I_SCREEN_START_LINE     = 0
*     I_SCREEN_END_COLUMN     = 0
*     I_SCREEN_END_LINE       = 0
*     I_HTML_HEIGHT_TOP       = 0
*     I_HTML_HEIGHT_END       = 0
*     IT_ALV_GRAPHICS         =
*     IT_HYPERLINK            =
*     IT_ADD_FIELDCAT         =
*     IT_EXCEPT_QINFO         =
*     IR_SALV_FULLSCREEN_ADAPTER        =
* IMPORTING
*     E_EXIT_CAUSED_BY_CALLER =
*     ES_EXIT_CAUSED_BY_USER  =
    TABLES
      t_outtab                = lt_scarr
* EXCEPTIONS
*     PROGRAM_ERROR           = 1
*     OTHERS                  = 2
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*& Form FRM_ALV_HEADER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_alv_header .
  DATA: lt_header TYPE slis_t_listheader,
        ls_header TYPE slis_listheader.

  CLEAR ls_header.
  ls_header-typ = 'H'.
  ls_header-info = 'ALV Header'.
  APPEND ls_header TO lt_header.

  CLEAR ls_header.
  ls_header-typ = 'S'.
  ls_header-key = 'User:'.
  ls_header-info = sy-uname.
  APPEND ls_header TO lt_header.

  CLEAR ls_header.
  ls_header-typ = 'A'.
  ls_header-info = 'Italic text in header.'.
  APPEND ls_header TO lt_header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_header
*     I_LOGO             =
*     I_END_OF_LIST_GRID =
*     I_ALV_FORM         =
    .


ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_ALV_FOOTER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_alv_footer .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ZSTATUS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_zstatus USING p_extab TYPE slis_t_extab.
  SET PF-STATUS 'PFALV'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_USR_CMND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_usr_cmnd USING p_ucomm TYPE sy-ucomm
                        ps_selfield TYPE slis_selfield.
  CASE p_ucomm.
    WHEN '&BACK'.
      LEAVE PROGRAM.
    WHEN 'ALV_BTN'.
      MESSAGE 'ALV_BTN clicked..!' TYPE 'I'.
  ENDCASE.
ENDFORM.
