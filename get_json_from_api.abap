*&---------------------------------------------------------------------*
*& Report ZFD_R_DENEME
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report zfd_r_deneme.

data: len         type i, "transmission packet length
      len_string  type        string,
      url         type string, "Interface Address
      http_client type ref to if_http_client, "http client
      post_string type        string,
      result      type        string.
data: it_header  type tihttpnvp.

data: lv_token  type zb2b_token,
      lv_return type i,
      lv_str    type string.

start-of-selection.


  call function 'ZB2B_FM_API_AUTHORIZATION'
    importing
      e_token      = lv_token
      e_returncode = lv_return.

  check lv_token is not initial.

  concatenate 'Bearer' lv_token into lv_token separated by space.

  lv_str = lv_token.

  url = 'http://api.isteerp.com/Dynamic/api/Order/Wholesale'.


  "Creating http client
  call method cl_http_client=>create_by_url
    exporting
      url                = url
    importing
      client             = http_client
    exceptions
      argument_not_found = 1
      plugin_not_active  = 2
      internal_error     = 3
      others             = 4.

  http_client->propertytype_accept_cookie = if_http_client=>co_enabled.

  call method http_client->request->set_method( if_http_request=>co_request_method_get ).
  http_client->request->set_header_field( name = 'x-csrf-token' value = 'Fetch' ).
  http_client->request->set_header_field( name = 'Accept' value = 'application/json' ).
  http_client->request->set_header_field( name = 'Content-Type' value = 'application/json; charset=utf-8' ).
  http_client->request->set_header_field( name = 'Authorization' value = lv_str ).

  "Send
  call method http_client->send
    exceptions
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3
      http_invalid_timeout       = 4
      others                     = 5.

  "Receiving
  call method http_client->receive
    exceptions
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3.
  "Extract returns the string
  result = http_client->response->get_cdata( ).
  "The string replacement carriage, or will be identified as # abap
*  replace all occurrences of regex '\n' in result with space.
  "Get the data returned by the interface
*  RESULT = HTTP_CLIENT->RESPONSE->GET_CDATA( ).

*  write: result.

  types: begin of stt_head,
           ordernumber            type string,
           memberid               type string,
           companyid              type string,
           orderdate              type string,
           deadline               type string,
           ordertypeid            type string,
           saleschannelid         type string,
           vatinclude             type string,
           customerid             type string,
           locationid             type string,
           qty                    type string,
           grossamount            type string,
           discountdetailamount   type string,
           discountdocumentamount type string,
           netamount              type string,
           vatamount              type string,
           totalamount            type string,
           exchangerate           type string,
           currencyid             type string,
           documentdesc           type string,
           oppid                  type string,
           giftboxnote            type string,
           invoicenote            type string,
           cargoid                type string,
           cargoname              type string,
           cargopaymenttypeid     type string,
           cargotrackingnumber    type string,
         end of stt_head.

  types: begin of stt_itm,
           ordernumber            type string,
           orderdetailid          type string,
           skuid                  type string,
           orderdetailtype        type string,
           productcode            type string,
           productname            type string,
           qty                    type string,
           price                  type string,
           vatrate                type string,
           currencyid             type string,
           discountpercent1       type string,
           discountpercent2       type string,
           discountpercent3       type string,
           discountamount         type string,
           discountamountdocument type string,
           amount                 type string,
           exchangerate           type string,
           staffcode              type string,
           campaignid             type string,
           promotionid            type string,
           detaildescription      type string,
           deadline               type string,
           barcode                type string,
         end of stt_itm.

  data: wa_h type stt_head,
        it_h like table of wa_h,
        wa_i type stt_itm,
        it_i like table of wa_i.

  data: lv_len  type i,
        lv_x    type c,
        lv_ilk  type i,
        lv_poss type i,
        lv_row  type i.

  types : begin of t_table ,
            f1 type string,
          end of t_table.
  types : begin of t_tablei ,
            hr type i,
            f1 type string,
            f2 type string,
          end of t_tablei.


  data: lt_tableh type table of t_table,
        ls_tableh type t_table.
  data: lt_tablei type table of t_tablei,
        ls_tablei type zb2b_s_export.

  data: t_json type table of  zb2b_s_export.

  clear lv_str.
  lv_str = result.
  replace all occurrences of ',"OrderPayments":[]' in lv_str with ''.
  replace all occurrences of ',"OrderInvoiceAddress":null' in lv_str with ''.
  replace all occurrences of ',"OrderShipmentAddress":null}' in lv_str with ''.
  replace all occurrences of ',"OrderDetails":[' in lv_str with '},'.
  replace all occurrences of '"' in lv_str with ''.
  replace all occurrences of '[' in lv_str with ''.
  replace all occurrences of ']' in lv_str with ''.
  replace all occurrences of '#' in lv_str with ''.



  lv_len = strlen( lv_str ).

  data: lv_lenf type i.

  lv_x = space.
  lv_ilk = 1.
  while lv_x ne 'X'.
    search lv_str for '}'.
    if sy-subrc eq 0.
      lv_poss = sy-fdpos.
      ls_tableh-f1 = lv_str+1(lv_poss).
      lv_poss = lv_poss + 1.
      replace all occurrences of '{' in ls_tableh-f1 with ''.
      replace all occurrences of '}' in ls_tableh-f1 with ''.
      append ls_tableh to lt_tableh.
      clear ls_tableh.
      lv_len = lv_len - lv_poss.
      lv_str = lv_str+lv_poss(lv_len).
    else.
      lv_x = 'X'.
    endif.
  endwhile.

  lv_x = space.
  lv_row = 1.

  loop at lt_tableh into ls_tableh.
    lv_x = space.
    lv_str = ls_tableh-f1.
    lv_len = strlen( lv_str ).
    while lv_x ne 'X'.
      search lv_str for ':'.
      if sy-subrc eq 0.
        lv_poss = sy-fdpos.
        ls_tablei-fieldn = lv_str(lv_poss).
        move lv_row to ls_tablei-jhead.
        replace all occurrences of ',' in ls_tablei-fieldn with ''.
        replace all occurrences of '#' in ls_tablei-fieldn with ''.
        lv_lenf = strlen( ls_tablei-fieldn ).
*      lv_lenf = lv_lenf - 5.
*      ls_tablei-fieldn = ls_tablei-fieldn+5(lv_lenf).
        ls_tablei-fieldn = ls_tablei-fieldn(lv_lenf).
        condense ls_tablei-fieldn no-gaps.
        lv_poss = lv_poss + 1.
        lv_len = lv_len - lv_poss.

        lv_str = lv_str+lv_poss(lv_len).
        search lv_str for ','.
        if sy-subrc eq 0.
          lv_poss = sy-fdpos.
*        ls_tablei-JVAL = lv_str+1(lv_poss).
          ls_tablei-jval = lv_str(lv_poss).
          lv_len = lv_len - lv_poss.
          lv_str = lv_str+lv_poss(lv_len).
          replace all occurrences of ',' in ls_tablei-jval with ''.
          append ls_tablei to t_json.
          clear ls_tablei.
        else.
          ls_tablei-jval = lv_str.

          append ls_tablei to t_json.
          clear ls_tablei.
          lv_x = 'X'.
        endif.
      else.
        lv_x = 'X'.
      endif.
    endwhile.
    lv_row = lv_row + 1.
  endloop.

  data: lv_no type int4,
        lv_c.
  lv_no = 0.
  loop at t_json into ls_tablei.
    if lv_no ne ls_tablei-jhead.
      if ls_tablei-fieldn eq 'OrderNumber'.
        lv_c = 'H'.
      else.
        lv_c = 'I'.
      endif.
      lv_no = ls_tablei-jhead.
    endif.
    if lv_c = 'H'.
      case ls_tablei-fieldn.
        when 'OrderNumber'.
          clear wa_h.
          wa_h-ordernumber = ls_tablei-jval.
        when 'MemberID'.
          wa_h-memberid = ls_tablei-jval.
        when 'CompanyID'.
          wa_h-companyid = ls_tablei-jval.
        when 'OrderDate'.
          wa_h-orderdate = ls_tablei-jval.
        when 'DeadLine'.
          wa_h-deadline = ls_tablei-jval.
        when 'OrderTypeID'.
          wa_h-ordertypeid = ls_tablei-jval.
        when 'SalesChannelId'.
          wa_h-saleschannelid = ls_tablei-jval.
        when 'VatInclude'.
          wa_h-vatinclude = ls_tablei-jval.
        when 'CustomerID'.
          wa_h-customerid = ls_tablei-jval.
        when 'LocationID'.
          wa_h-locationid = ls_tablei-jval.
        when 'Qty'.
          wa_h-qty = ls_tablei-jval.
        when 'GrossAmount'.
          wa_h-grossamount = ls_tablei-jval.
        when 'DiscountDetailAmount'.
          wa_h-discountdetailamount = ls_tablei-jval.
        when 'DiscountDocumentAmount'.
          wa_h-discountdocumentamount = ls_tablei-jval.
        when 'NetAmount'.
          wa_h-netamount = ls_tablei-jval.
        when 'VatAmount'.
          wa_h-vatamount = ls_tablei-jval.
        when 'TotalAmount'.
          wa_h-totalamount = ls_tablei-jval.
        when 'ExchangeRate'.
          wa_h-exchangerate = ls_tablei-jval.
        when 'CurrencyID'.
          wa_h-currencyid = ls_tablei-jval.
        when 'DocumentDesc'.
          wa_h-documentdesc = ls_tablei-jval.
        when 'OppID'.
          wa_h-oppid = ls_tablei-jval.
        when 'GiftBoxNote'.
          wa_h-giftboxnote = ls_tablei-jval.
        when 'InvoiceNote'.
          wa_h-invoicenote = ls_tablei-jval.
        when 'CargoID'.
          wa_h-cargoid = ls_tablei-jval.
        when 'CargoName'.
          wa_h-cargoname = ls_tablei-jval.
        when 'CargoPaymentTypeID'.
          wa_h-cargopaymenttypeid = ls_tablei-jval.
        when 'CargoTrackingNumber'.
          wa_h-cargotrackingnumber = ls_tablei-jval.
          append wa_h to it_h.
      endcase.
    else.
      case ls_tablei-fieldn.
        when 'OrderDetailID'.
          clear wa_i.
          wa_i-ordernumber = wa_h-ordernumber.
          wa_i-orderdetailid = ls_tablei-jval.
        when 'SkuID'.
          wa_i-skuid = ls_tablei-jval.
        when 'OrderDetailType'.
          wa_i-orderdetailtype = ls_tablei-jval.
        when 'ProductCode'.
          wa_i-productcode = ls_tablei-jval.
        when 'ProductName'.
          wa_i-productname = ls_tablei-jval.
        when 'Qty'.
          wa_i-qty = ls_tablei-jval.
        when 'Price'.
          wa_i-price = ls_tablei-jval.
        when 'VatRate'.
          wa_i-vatrate = ls_tablei-jval.
        when 'CurrencyID'.
          wa_i-currencyid = ls_tablei-jval.
        when 'DiscountPercent1'.
          wa_i-discountpercent1 = ls_tablei-jval.
        when 'DiscountPercent2'.
          wa_i-discountpercent2 = ls_tablei-jval.
        when 'DiscountPercent3'.
          wa_i-discountpercent3 = ls_tablei-jval.
        when 'DiscountAmount'.
          wa_i-discountamount = ls_tablei-jval.
        when 'DiscountAmountDocument'.
          wa_i-discountamountdocument = ls_tablei-jval.
        when 'Amount'.
          wa_i-amount = ls_tablei-jval.
        when 'ExchangeRate'.
          wa_i-exchangerate = ls_tablei-jval.
        when 'StaffCode'.
          wa_i-staffcode = ls_tablei-jval.
        when 'CampaignID'.
          wa_i-campaignid = ls_tablei-jval.
        when 'PromotionID'.
          wa_i-promotionid = ls_tablei-jval.
        when 'DetailDescription'.
          wa_i-detaildescription = ls_tablei-jval.
        when 'DeadLine'.
          wa_i-deadline = ls_tablei-jval.
        when 'Barcode'.
          wa_i-barcode = ls_tablei-jval.
          append wa_i to it_i.
      endcase.
    endif.
  endloop.

  write: result.
