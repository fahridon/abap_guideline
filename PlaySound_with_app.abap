report zfd_r_deneme.

data lv_result.

call method cl_gui_frontend_services=>file_exist
  exporting
    file                 = 'C:\ses\PlaySound.exe'
  receiving
    result               = lv_result
  exceptions
    cntl_error           = 1
    error_no_gui         = 2
    wrong_parameter      = 3
    not_supported_by_gui = 4
    others               = 5.
if lv_result = 'X'.
  data lv_cline(50).
  lv_cline = 'C:\ses\error.wav'.
  call function 'WS_EXECUTE'
    exporting
      commandline        = lv_cline
      inform             = ''
      program            = 'C:\ses\PlaySound.exe'
    exceptions
      frontend_error     = 1
      no_batch           = 2
      prog_not_found     = 3
      illegal_option     = 4
      gui_refuse_execute = 5
      others             = 6.
endif.
