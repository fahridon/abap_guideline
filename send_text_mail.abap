report zfd_r_deneme.

types: begin of ty_lines,
         line type char255,
       end of ty_lines.
data: ti_lines type standard table of ty_lines,
      wa_lines type ty_lines.
data: title          type string,
      sender_email   type string,
      receiver_email type string.

title = 'Mail başlığı-TEST'.

clear wa_lines.
wa_lines-line = 'Merhaba.(Satır-1)'.
append wa_lines to ti_lines.

clear wa_lines.
wa_lines-line = 'Bu bir test maili. (Satır-2)'.
append wa_lines to ti_lines.

sender_email = 'fahridonmez@test.com.tr'.
receiver_email = 'fahridonmez@test.com.tr'.

call function 'EFG_GEN_SEND_EMAIL'
  exporting
    i_title                = title
    i_sender               = sender_email
    i_recipient            = receiver_email
    i_flg_commit           = 'X'
    i_flg_send_immediately = 'X'
  tables
    i_tab_lines            = ti_lines
  exceptions
    not_qualified          = 1
    failed                 = 2
    others                 = 3.

if sy-subrc ne 0.
  write: 'hata...!'.
else.
  write: 'basarili...!'.
endif.
