class zaws_example_001 definition
  public
  final
  create public .

  public section.
    interfaces if_oo_adt_classrun.

  protected section.
  private section.
endclass.



class zaws_example_001 implementation.
  method if_oo_adt_classrun~main.
    data method type string value 'GET'.
    data service type string value 'ec2'.
    data host type string value 'ec2.amazonaws.com'.
    data region type string value 'us-east-1'.
    data endpoint type string value 'https://ec2.amazonaws.com'.

    data access_key type string value ''.
    data secret_key type string value ''.

    zaws_sigv4_utilities=>get_current_timestamp( importing amz_date = data(amzdate)
                                                           datestamp = data(datestamp) ).

    data(canonical_querystring) = zaws_sigv4_utilities=>get_canonical_querystring( value #(
      ( name = 'Action' value = 'DescribeRegions' )
      ( name = 'Version' value = '2013-10-15' )
    ) ).

    data(canonical_headers) = zaws_sigv4_utilities=>get_canonical_headers( value #(
      ( name = 'host' value = host )
      ( name = 'x-amz-date' value = amzdate )
    ) ).

    data(signed_headers) = zaws_sigv4_utilities=>get_signed_headers( value #(
      ( name = 'host' )
      ( name = 'x-amz-date' )
    ) ).

    data(payload_hash) = zaws_sigv4_utilities=>get_hash( message = '' ).

    data(canonical_request) = zaws_sigv4_utilities=>get_canonical_request( http_method = method
                                                                           canonical_querystring = canonical_querystring
                                                                           canonical_headers = canonical_headers
                                                                           canonical_uri = '/'
                                                                           signed_headers = signed_headers
                                                                           payload_hash = payload_hash ).

    data(algorithm) = zaws_sigv4_utilities=>get_algorithm( ).

    data(credential_scope) = zaws_sigv4_utilities=>get_credential_scope( datestamp = datestamp
                                                                         region = region
                                                                         service = service ).

    data(string_to_sign) = zaws_sigv4_utilities=>get_string_to_sign( algorithm = algorithm
                                                                     amz_date = amzdate
                                                                     canonical_request = canonical_request
                                                                     credential_scope = credential_scope ).

    data(signing_key) = zaws_sigv4_utilities=>get_signature_key( key = secret_key
                                                                 datestamp = datestamp
                                                                 region_name = region
                                                                 service_name = service ).

    data(signature) = zaws_sigv4_utilities=>get_signature( signing_key = signing_key
                                                           string_to_sign = string_to_sign ).

    data(credential) = zaws_sigv4_utilities=>get_credential( access_key = access_key
                                                             credential_scope = credential_scope ).

    data(authorization_header) = zaws_sigv4_utilities=>get_authorization_header( algorithm = algorithm
                                                                                 credential = credential
                                                                                 signature = signature
                                                                                 signed_headers = signed_headers ).

    try.
        cl_http_client=>create_by_url(
          exporting url = |{ endpoint }?{ canonical_querystring }|
          importing client = data(http_client)
        ).

        data(rest_client) = new cl_rest_http_client( io_http_client = http_client ).

        rest_client->if_rest_client~set_request_header( iv_name = 'x-amz-date' iv_value = amzdate ).
        rest_client->if_rest_client~set_request_header( iv_name = 'Authorization' iv_value = authorization_header ).


        rest_client->if_rest_client~get( ).
        data(response) = rest_client->if_rest_client~get_response_entity( ).
        out->write( response->get_string_data(  ) ).

      catch cx_root into data(x_root).
        out->write( x_root->get_text(  ) ).
        out->write( x_root->get_longtext(  ) ).
    endtry.

  endmethod.

endclass.
