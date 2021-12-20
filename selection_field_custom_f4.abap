report zfd_r_deneme.

*---------------------------------------------------------------------*
*                             C O N S T A N T S                       *
*---------------------------------------------------------------------*
constants:
  c_z004          type zsd_s_mt_ikitarih-auart value 'Z004',
  c_zt01          type zsd_s_mt_ikitarih-auart value 'ZT01',
  c_lgort         type mska-lgort value '0008',
  lc_long_text(1) type c value 'L',
  c_mustr_l       type dfies-fieldname value 'S_MUSTR-LOW'.

types: begin of ty_mustr,
         mustr like zmme_002-mustr,
       end of ty_mustr.

data: lt_mustr   type standard table of ty_mustr,
      it_return1 type standard table of ddshretval,
      wa_return1 type ddshretval.

tables: zmme_002.

*---------------------------------------------------------------------*
*                  S E L E C T I O N   S C R E E N                    *
*---------------------------------------------------------------------*
selection-screen begin of block bl1 with frame title text-000.
parameters : p_werks like t001w-werks obligatory.
select-options : s_matnr for zmme_002-matnr,
                 s_mustr for zmme_002-mustr.
selection-screen end of block bl1 .

initialization.
*---------------------------------------------------------------------*
  p_werks = '1100'.

  select distinct mustr from zmme_002
  into table lt_mustr
  where mustr <> ''.
  if  sy-subrc eq 0.
    sort lt_mustr by mustr.
  endif.

at selection-screen on value-request for s_mustr-low.
  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
    exporting
      retfield        = c_mustr_l
      value_org       = 'S'
    tables
      value_tab       = lt_mustr
      return_tab      = it_return1
    exceptions
      parameter_error = 1
      no_values_found = 2
      others          = 3.

  if it_return1 is not initial.
    loop at it_return1 into wa_return1.
      s_mustr-low = wa_return1-fieldval.
    endloop.
  endif.
