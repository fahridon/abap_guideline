*&---------------------------------------------------------------------*
*& Report zfd_r_oop_mvc_report
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

* Source:
*https://www.erpqna.com/object-oriented-programming-in-abap-mvc-part-iv/

REPORT zfd_r_oop_mvc_report.

INCLUDE zfd_r_oop_mvc_report_top.

INCLUDE zfd_r_oop_mvc_report_cls.

DATA: o_display TYPE REF TO cl_alv.
DATA: o_con     TYPE REF TO cl_controller .

INITIALIZATION .
*Creating object of CL_ALV(View class) and CL_CONTROLLER(controller class).
  CREATE OBJECT : o_display ,o_con.

START-OF-SELECTION.
*call the method GET_OBJECT to get the object of CL_FETCH(model class)
  CALL METHOD o_con->get_object
    EXPORTING
      gen_name = 'CL_FETCH'.

* GET_SEL method of class CL_FETCH to get the object of CL_SEL class
  CALL METHOD o_con->obj_model->get_sel.
* Once we have the obejct of CL_SEL we can call its method GET_SCREEN
*to get the selection screen
  CALL METHOD o_con->obj_model->sel_obj->get_screen(
    EXPORTING
      lp_carrid = p_carrid
      ls_connid = s_connid[] ).
*Finally we can call FETCH_DATA method and pass our data to controller
  CALL METHOD o_con->obj_model->fetch_data.
*The controller  will turn pass the data CL_ALV our VIEW class.
END-OF-SELECTION .
*Display data
  CALL METHOD o_display->display_alv
    EXPORTING
      con_obj = o_con.
