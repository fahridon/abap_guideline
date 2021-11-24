*&---------------------------------------------------------------------*
*& ALV GRID fieldcatalog MERGE
*&---------------------------------------------------------------------*

report zfd_r_deneme.

* Fiealdcatalog tanýmlama
data: gt_fieldcat type slis_t_fieldcat_alv with header line.
data: gs_layout type slis_layout_alv.

* Ýnternal Tablomuz
data: begin of gt_data occurs 0,
        vbeln like vbak-vbeln,  "sipariþ numarasý
        posnr like vbap-posnr,  "kalem numarasý
        matnr like vbap-matnr,  "malzeme numarasý
      end of gt_data.

*Tablomuzu dolduralým
select vbak~vbeln vbap~posnr vbap~matnr  into table gt_data
  from vbak
  inner join vbap
  on vbap~vbeln eq vbak~vbeln
  up to 100 rows.

*Merge iþlemi
call function 'REUSE_ALV_FIELDCATALOG_MERGE'
  exporting
    i_program_name         = sy-repid
    i_internal_tabname     = 'GT_DATA'
    i_inclname             = sy-repid
  changing
    ct_fieldcat            = gt_fieldcat[]
  exceptions
    inconsistent_interface = 1
    program_error          = 2
    others                 = 3.

* aLANLARIN BAÞLIKLARINI SIÐDIR
gs_layout-colwidth_optimize = 'X'.

*Alv Listeleme
call function 'REUSE_ALV_GRID_DISPLAY'
  exporting
    is_layout     = gs_layout
    it_fieldcat   = gt_fieldcat[]
  tables
    t_outtab      = gt_data
  exceptions
    program_error = 1
    others        = 2.
