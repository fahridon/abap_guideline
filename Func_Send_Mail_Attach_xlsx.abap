FUNCTION zsd_fm_inv_mail_china.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_NAST) TYPE  NAST
*"----------------------------------------------------------------------

  DATA: lv_kunag LIKE vbrk-kunag VALUE '0000001234'.

  CONSTANTS lc_sender TYPE ad_smtpadr VALUE 'test@sendmail.com' .

  SELECT *
    FROM vbrk
    WHERE vbeln = @is_nast-objky
    INTO @DATA(ls_vbrk).
  ENDSELECT.

  CHECK ls_vbrk-kunag EQ lv_kunag.

* Get invoice item data for xlsx attach file

  SELECT
    vbkd~bstkd,
    vbrp~aubel,
    vbrp~vgbel,
    vbrp~matnr,
    mara~zz_mold,
    vbrp~arktx,
    vbrp~fkimg,
    vbrp~vrkme,
    vbrp~netwr,
    vbrk~waerk,
    vbrp~ntgew,
    vbrp~brgew,
    vbrp~gewei,
    vbrp~volum,
    vbrp~voleh
    FROM vbrp
    INNER JOIN vbrk ON vbrk~vbeln EQ vbrp~vbeln
    LEFT OUTER JOIN mara ON mara~matnr EQ vbrp~matnr
    LEFT OUTER JOIN vbkd ON vbkd~vbeln EQ vbrp~aubel
    WHERE vbrp~vbeln EQ @ls_vbrk-vbeln
    INTO TABLE @DATA(lt_vbrp).

  CHECK lt_vbrp[] IS NOT INITIAL.

* get mail receiver
  SELECT
    email,
    rctyp
    FROM zsd_t_rec_invmail
    INTO TABLE @DATA(lt_receivers).

  CHECK lt_receivers[] IS NOT INITIAL.

* mail definations

  DATA lo_send_request   TYPE REF TO cl_bcs.
  DATA lo_document       TYPE REF TO cl_document_bcs.
  DATA recipient      TYPE REF TO if_recipient_bcs.
  DATA bcs_exception  TYPE REF TO cx_bcs.

  DATA main_text      TYPE bcsy_text.
  DATA sent_to_all    TYPE os_boolean.


* send mail

  DATA: lv_subject(50),
        lv_file_name(50).

  lv_subject = ls_vbrk-vbeln && '-Invoice-' && ls_vbrk-fkdat.
  lv_file_name = lv_subject && '.xlsx'.


  GET REFERENCE OF lt_vbrp INTO DATA(lo_data_ref).

  DATA lv_xstring TYPE xstring.


  FIELD-SYMBOLS: <fs_data> TYPE ANY TABLE.

  ASSIGN lo_data_ref->* TO <fs_data>.

  TRY.
      cl_salv_table=>factory(
        IMPORTING r_salv_table = DATA(lo_table)
        CHANGING  t_table      = <fs_data> ).

      DATA(lt_fcat) =
        cl_salv_controller_metadata=>get_lvc_fieldcatalog(
          r_columns      = lo_table->get_columns( )
          r_aggregations = lo_table->get_aggregations( ) ).

      DATA(lo_result) =
        cl_salv_ex_util=>factory_result_data_table(
          r_data         = lo_data_ref
          t_fieldcatalog = lt_fcat ).

      cl_salv_bs_tt_util=>if_salv_bs_tt_util~transform(
        EXPORTING
          xml_type      = if_salv_bs_xml=>c_type_xlsx
          xml_version   = cl_salv_bs_a_xml_base=>get_version( )
          r_result_data = lo_result
          xml_flavour   = if_salv_bs_c_tt=>c_tt_xml_flavour_export
          gui_type      = if_salv_bs_xml=>c_gui_type_gui
        IMPORTING
          xml           = lv_xstring ).
    CATCH cx_root.
      CLEAR lv_xstring.
  ENDTRY.


  TRY.

*     -------- create persistent send request ------------------------
      lo_send_request = cl_bcs=>create_persistent( ).

*     -------- set sender --------------------------------------------
      lo_send_request->set_sender( cl_cam_address_bcs=>create_internet_address( lc_sender ) ).

*     -------- create and set document with attachment ---------------
*     create document object from internal table with text
      APPEND lv_subject TO main_text.
      lo_document = cl_document_bcs=>create_document(
        i_type    = 'RAW'
        i_text    = main_text
        i_subject = lv_subject ).

      "Add attachment
      lo_document->add_attachment(
          i_attachment_type    = 'xls'
          i_attachment_size    = CONV #( xstrlen( lv_xstring ) )
          i_attachment_subject = lv_file_name
          i_attachment_header  = VALUE #( ( line = lv_file_name ) )
          i_att_content_hex    = cl_bcs_convert=>xstring_to_solix( lv_xstring )
       ).

*     add document object to send request
      lo_send_request->set_document( lo_document ).

*     --------- add recipient (e-mail address) -----------------------
      LOOP AT lt_receivers ASSIGNING FIELD-SYMBOL(<receivers>).
*     create recipient object
        recipient = cl_cam_address_bcs=>create_internet_address( <receivers>-email ).

*     add recipient object to send request
        CASE <receivers>-rctyp.
          WHEN 'TO'.
            lo_send_request->add_recipient( recipient ).
          WHEN 'CC'.
            CALL METHOD lo_send_request->add_recipient
              EXPORTING
                i_recipient = recipient
                i_copy      = 'X'.
          WHEN 'BCC'.
            CALL METHOD lo_send_request->add_recipient
              EXPORTING
                i_recipient  = recipient
                i_blind_copy = 'X'.
          WHEN OTHERS.
            lo_send_request->add_recipient( recipient ).
        ENDCASE.
      ENDLOOP.
*     ---------- send document ---------------------------------------

      sent_to_all = lo_send_request->send( i_with_error_screen = 'X' ).

      IF sent_to_all IS INITIAL.

      ELSE.
      
      ENDIF.

    CATCH cx_bcs INTO bcs_exception.
      MESSAGE i865(so) WITH bcs_exception->error_type.
  ENDTRY.



ENDFUNCTION.
