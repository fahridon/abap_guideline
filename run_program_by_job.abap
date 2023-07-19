FORM create_job USING
p_vttk TYPE vttkvb
p_material TYPE vhilm.

FIELD-SYMBOLS: TYPE rsparams.

DATA: lt_selection TYPE TABLE OF rsparams
,lwa_print_parameters TYPE pri_params
,lv_valid TYPE c,
lv_immed TYPE btcchar1
,lv_released TYPE btcchar1.

DATA: lv_job_name LIKE tbtcjob-jobname,
lv_jobcount LIKE tbtcjob-jobcount.

*1) Job_open
CONCATENATE ‘ADD HU IN SHP’ p_vttk-tknum
INTO lv_job_name SEPARATED BY
space.

” start creation of background job
CALL FUNCTION ‘JOB_OPEN’
EXPORTING
jobname = lv_job_name
IMPORTING
jobcount = lv_jobcount
EXCEPTIONS
cant_create_job = 1
invalid_job_data = 2
jobname_missing = 3
OTHERS = 4.
IF sy-subrc <> 0.

ENDIF.

*(2) Job_submit
” add step to job
INSERT INITIAL LINE INTO TABLE lt_selection ASSIGNING .
-selname = ‘P_TKNUM’.
-kind = ‘P’.
-low = p_vttk-tknum.
APPEND TO lt_selection.

INSERT INITIAL LINE INTO TABLE lt_selection ASSIGNING .
-selname = ‘P_EXIDV’.
-kind = ‘P’.
-low = p_material-exidv.
APPEND TO lt_selection.

INSERT INITIAL LINE INTO TABLE lt_selection ASSIGNING .
-selname = ‘P_VHILM’.
-kind = ‘P’.
-low = p_material-vhilm.
APPEND TO lt_selection.

* get print parameter

CALL FUNCTION ‘GET_PRINT_PARAMETERS’
EXPORTING
destination = ‘LOCL’
no_dialog = ‘X’
layout = ‘X_65_132′
line_count = ’60’
line_size = ‘130’
IMPORTING
out_parameters = lwa_print_parameters
valid = lv_valid
EXCEPTIONS
archive_info_not_found = 1
invalid_print_params = 2
invalid_archive_params = 3
OTHERS = 4.

* set job step
SUBMIT zsd_r_shpmnt_tr_hu_crt_bdc
WITH SELECTION-TABLE lt_selection
USER sy-uname VIA JOB lv_job_name NUMBER lv_jobcount AND RETURN
TO SAP-SPOOL
SPOOL PARAMETERS lwa_print_parameters
WITHOUT SPOOL DYNPRO .

*(3) Job_close

lv_immed = abap_true.

CALL FUNCTION ‘JOB_CLOSE’
EXPORTING
jobcount = lv_jobcount
jobname = lv_job_name
strtimmed = lv_immed
IMPORTING
job_was_released = lv_released
EXCEPTIONS
cant_start_immediate = 1
invalid_startdate = 2
jobname_missing = 3
job_close_failed = 4
job_nosteps = 5
job_notex = 6
lock_failed = 7
invalid_target = 8
OTHERS = 9.
IF sy-subrc <> 0.

ENDIF.

ENDFORM.
