report zfd_r_deneme.

data: exc_ref       type ref to cx_sy_native_sql_error,
      error_text    type string,
      lv_date1      type string,
      lv_date2      type string,
      gs_orgu1612   type zpp_s_doto_orgu,
      lv_start_date type string.

data: begin of wa_barkod,
        barkod_no like zpp_t_barkod-barkod_no,
        matnr     like zpp_t_barkod-matnr,
        charg     like zpp_t_barkod_itm-charg,
        j_3asize  like zpp_t_barkod_itm-j_3asize,
      end of wa_barkod,
      it_barkod like table of wa_barkod.

data:
  i_date1 type  datum,
  i_date2 type  datum,
  i_conn  type  dbcon_name,
  t_data  type  zpp_tt_doto_orgu.

concatenate i_date1+0(4) i_date1+4(2) i_date1+6(2) into lv_date1 separated by '-'.
concatenate i_date2+0(4) i_date2+4(2) i_date2+6(2) into lv_date2 separated by '-'.

lv_start_date = '2019-11-25 08:30:00.000'.

if i_conn(1) eq 'O'.
  lv_start_date = '2020-06-15 08:30:00.000'.
endif.

i_date1 = sy-datum.
i_date1 = sy-datum + 1.
i_conn = 'OD_TEYIT'.

try.
    exec sql.
      CONNECT TO  :I_CONN
    endexec.

    if sy-subrc ne 0.
      message id 'ZPP' type 'E' number '000'
      with 'Database bağlanılamadı...'  sy-msgv2 sy-msgv3 sy-msgv4 raising error.
    endif.


    exec sql .
      SET CONNECTION :I_CONN
    endexec.

  catch cx_sy_native_sql_error into exc_ref.
    error_text = exc_ref->get_text( ).
    message id 'ZPP' type 'E' number '000'
    with error_text sy-msgv2 sy-msgv3 sy-msgv4 raising error.

endtry .

try.


    exec sql.
      OPEN C FOR
      SELECT
      DateTime,
      BARCODE,
      KALITE_2,
      COP
      from VW_TABLE1_mak_non_DETEX_bar_strt_c
      WHERE DateTime >= :lv_start_date and
      DateTime between :lv_date1 and :lv_date2 and
      ( KALITE_2 > 0 or COP > 0 )
    endexec.
    do.
      exec sql.
        FETCH NEXT C into
        :gs_orgu1612-dattim,
        :gs_orgu1612-barkod_no,
        :gs_orgu1612-kalite_2,
        :gs_orgu1612-cop
      endexec.
      if sy-subrc = 0.
        concatenate gs_orgu1612-dattim+0(4) gs_orgu1612-dattim+5(2) gs_orgu1612-dattim+8(2) into gs_orgu1612-erdat.
        concatenate gs_orgu1612-dattim+11(2) gs_orgu1612-dattim+14(2) gs_orgu1612-dattim+17(2) into gs_orgu1612-erzet.
        append gs_orgu1612 to t_data.
      else.
        exit.
      endif.
    enddo.

  catch cx_sy_native_sql_error into exc_ref.
    error_text = exc_ref->get_text( ).
    message id 'ZPP' type 'E' number '000'
    with error_text sy-msgv2 sy-msgv3 sy-msgv4 raising error.
endtry.

try.



    exec sql.
      CLOSE C
    endexec.


    exec sql.
      DISCONNECT :I_CONN
    endexec.

  catch cx_sy_native_sql_error into exc_ref.
    error_text = exc_ref->get_text( ).
    message error_text type 'I' raising error.
    message id 'ZPP' type 'E' number '000'
    with error_text sy-msgv2 sy-msgv3 sy-msgv4 raising error.

endtry .

if t_data[] is not initial.
  select
    a~barkod_no
    a~matnr
    b~charg
    b~j_3asize
    into table it_barkod
    from zpp_t_barkod as a
    inner join zpp_t_barkod_itm as b on a~barkod_no eq b~barkod_no
    for all entries in t_data
    where a~barkod_no eq t_data-barkod_no.
  if sy-subrc eq 0.
    sort it_barkod by barkod_no.
    loop at t_data into gs_orgu1612.
      read table it_barkod into wa_barkod
      with key barkod_no = gs_orgu1612-barkod_no
      binary search.
      if sy-subrc eq 0.
        gs_orgu1612-matnr = wa_barkod-matnr.
        gs_orgu1612-j_3asize = wa_barkod-j_3asize.
        gs_orgu1612-charg = wa_barkod-charg.
      endif.
      modify t_data from gs_orgu1612.
      clear wa_barkod.
    endloop.

  endif.

endif.
