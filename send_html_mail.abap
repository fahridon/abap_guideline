report zfd_r_deneme.

*---------------------------------------------------------------------*
* V A R I A B L E S *
*---------------------------------------------------------------------*
data:
  t_header  type standard table of w3head with header line, "Header
  t_fields  type standard table of w3fields with header line, "Fields
  t_html    type standard table of w3html, "Html
  wa_header type w3head,
  w_head    type w3head.

data:begin of it_data occurs 0,
       updkz    like zpp_t_prodord_l-updkz, " Icron güncelleme göst.
       aufnr    like zpp_t_prodord_l-aufnr, " Sipariş
       matnr    like zpp_t_prodord_l-matnr, " Malzeme
       menge    like zpp_t_prodord_l-menge, " Miktar
       meins    like zpp_t_prodord_l-meins, " ÖB
       beden    like zpp_t_prodord_l-beden, " Matris
       zzmakina like zpp_t_prodord_l-zzmakina, " Makina Kodu
       type     like zpp_t_prodord_l-type, " Mesaj Tipi
       message  like zpp_t_prodord_l-message, " Mesaj
       crnam    like zpp_t_prodord_l-crnam, " Yaratan
       crdat    like zpp_t_prodord_l-crdat, " Y.Tarihi
       crtim    like zpp_t_prodord_l-crtim, " Y.Saati
     end of it_data,
     wa_data like line of it_data.

* Data Declarations
data: lt_mailsubject type sodocchgi1.
data: lt_mailrecipients type standard table of somlrec90 with header
line.
data: lt_mailtxt type standard table of soli with header
line.

data: begin of t_mail occurs 0,
        receiver type zpp_t_mailgrup-smtp_addr,
      end of t_mail,
      ls_mail like line of t_mail.
*---------------------------------------------------------------------*
* S E L E C T I O N S C R E E N *
*---------------------------------------------------------------------*
*SELECTION-SCREEN BEGIN OF BLOCK BL1 WITH FRAME TITLE TEXT-000.
*PARAMETERS : P_WERKS LIKE T001W-WERKS OBLIGATORY.
*SELECT-OPTIONS : S_MATNR FOR MARA-MATNR.
*SELECTION-SCREEN END OF BLOCK BL1 .

*---------------------------------------------------------------------*
* E V E N T S *
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*
initialization.
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*
at selection-screen output.
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*
at selection-screen.
*---------------------------------------------------------------------*
* Validate Input At Selection Screen
*PERFORM screen_validation.

*---------------------------------------------------------------------*
start-of-selection.
*---------------------------------------------------------------------*
  perform build_data.
  perform send_mail.
*---------------------------------------------------------------------*
end-of-selection.
*&---------------------------------------------------------------------*
*& Form BUILD_DATA
*&---------------------------------------------------------------------*

form build_data .
  data: lv_date1 type sy-datum.
  data: lv_date2 type sy-datum.

  lv_date1 = sy-datum .
  lv_date2 = sy-datum - 1.

* başarılı olmayan üretim siparişi işlemleri
  select log~updkz
  log~aufnr
  log~matnr
  log~menge
  log~meins
  log~beden
  log~zzmakina
  log~type
  log~message
  log~crnam
  log~crdat
  log~crtim
  from zpp_t_prodord_l as log
  into table it_data
  where type ne 'S'
  and ( ( log~crdat eq lv_date1 and log~crtim le sy-uzeit )
  or ( log~crdat eq lv_date2 and log~crtim ge sy-uzeit ) ).

* mak no boş olan siparişler
  select log~updkz
  log~aufnr
  log~matnr
  log~menge
  log~meins
  log~beden
  log~zzmakina
  log~type
  log~message
  log~crnam
  log~crdat
  log~crtim from zpp_t_prodord_l as log
  inner join aufk
  on log~aufnr eq aufk~aufnr
  appending table it_data
  where ( ( log~crdat eq lv_date1 and log~crtim le sy-uzeit )
  or ( log~crdat eq lv_date2 and log~crtim ge sy-uzeit ) )
  and aufk~loekz eq ''
  and aufk~zzmakina eq ''.

  loop at it_data into wa_data.
    if wa_data-type eq 'S'.
      wa_data-type = 'E'.
      wa_data-message = 'SAP üretim siparişi Makine No boş olamaz!'.
      modify it_data from wa_data.
    endif.
  endloop.
  if it_data[] is initial.
    write: / 'Kayıt bulunamadı!'.
  endif.
endform. " BUILD_DATA
*&---------------------------------------------------------------------*
*& Form SEND_MAIL
*&---------------------------------------------------------------------*
form send_mail .
  check it_data[] is not initial.
*-Fill the Column headings and Properties
  data: gt_fieldcat type slis_t_fieldcat_alv with header line.
*Merge işlemi
  call function 'REUSE_ALV_FIELDCATALOG_MERGE'
    exporting
      i_program_name         = sy-repid
      i_internal_tabname     = 'IT_DATA'
      i_inclname             = sy-repid
    changing
      ct_fieldcat            = gt_fieldcat[]
    exceptions
      inconsistent_interface = 1
      program_error          = 2
      others                 = 3.
  loop at gt_fieldcat.
    w_head-text = gt_fieldcat-seltext_s.
    if gt_fieldcat-fieldname = 'MESSAGE'.
      w_head-text = 'Hata Mesajı'.
    endif.
*-Populate the Column Headings
    call function 'WWW_ITAB_TO_HTML_HEADERS'
      exporting
        field_nr = sy-tabix
        text     = w_head-text
        fgcolor  = 'black'
        bgcolor  = 'orange'
      tables
        header   = t_header.
*-Populate Column Properties
    call function 'WWW_ITAB_TO_HTML_LAYOUT'
      exporting
        field_nr = sy-tabix
        fgcolor  = 'black'
        size     = '3'
      tables
        fields   = t_fields.
  endloop.
*-Title of the Display
  wa_header-text = 'SAP Icron RFC hata detayları.' .
  wa_header-font = 'Arial'.
  wa_header-size = '2'.
*-Preparing the HTML from Intenal Table
  refresh t_html.
  call function 'WWW_ITAB_TO_HTML'
    exporting
      table_header = wa_header
    tables
      html         = t_html
      fields       = t_fields
      row_header   = t_header
      itable       = it_data.

* Recipients
  select smtp_addr as receiver
  from zpp_t_mailgrup into table t_mail
  where pgmna eq 'ZPP_R_ICRON_MAIL_HATA'.

  if t_mail[] is initial.
    lt_mailrecipients-receiver = 'user@domain.com.tr'.
    lt_mailrecipients-rec_type = 'U'.
    append lt_mailrecipients .
    clear lt_mailrecipients .
  else.
    loop at t_mail into ls_mail.
      lt_mailrecipients-receiver = ls_mail-receiver.
      lt_mailrecipients-rec_type = 'U'.
      append lt_mailrecipients .
      clear lt_mailrecipients .
    endloop.
  endif.

* Subject.
  lt_mailsubject-obj_name = 'PENTI FABRIKA'.
  lt_mailsubject-obj_langu = sy-langu.
  lt_mailsubject-obj_descr = 'SAP Icron Örgü Üretim Siparişi Hata'.

* Mail Contents
  lt_mailtxt[] = t_html[].

* Send Mail
  call function 'SO_NEW_DOCUMENT_SEND_API1'
    exporting
      commit_work                = ''
      put_in_outbox              = 'X'
      document_data              = lt_mailsubject
      document_type              = 'HTM'
    tables
      object_content             = lt_mailtxt
      receivers                  = lt_mailrecipients
    exceptions
      too_many_receivers         = 1
      document_not_sent          = 2
      document_type_not_exist    = 3
      operation_no_authorization = 4
      parameter_error            = 5
      x_error                    = 6
      enqueue_error              = 7
      others                     = 8.
  if sy-subrc eq 0.
    commit work and wait.
    submit rsconn01 with mode = 'INT' and return.
    write: / 'Mail gönderildi...'.
  else.
    write: / 'hata:',sy-subrc.
  endif.

endform. " SEND_MAIL
