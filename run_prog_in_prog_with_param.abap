*&---------------------------------------------------------------------*
*& Report ZHR_HTRICM00_TO_PYS
*&---------------------------------------------------------------------*
*03.12.2021   id:0000247  JOB       IK bordro kontrol job       FDONMEZ
*&---------------------------------------------------------------------*
report zhr_htricm00_to_pys.

data: lv_pabrp type pnppabrp,
      lv_pabrj type pnppabrj.

ranges : r_werks for pernr-werks.

r_werks-sign = 'I'.
r_werks-option = 'EQ'.
r_werks-low = '1000'.
append r_werks.

lv_pabrp = sy-datum+4(2).
lv_pabrj = sy-datum(4).


submit zhr_htricm00 with pnpxabkr = '11'
                     with pnptimra = 'X'
                     with pnppabrp = lv_pabrp
                     with pnppabrj = lv_pabrj
                     with pnpwerks in r_werks
                     with p_repno = '3'
                     with p_bno = 'X'
                     with  p_pys = 'PYS'.
if sy-subrc eq 0.
  write:/ 'Tamam...'.
else.
  write:/ 'Hata..!'.
endif.
