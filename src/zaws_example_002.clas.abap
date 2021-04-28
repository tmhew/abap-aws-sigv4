class zaws_example_002 definition
  public
  final
  create public .

  public section.
    interfaces if_oo_adt_classrun.

  protected section.
  private section.
endclass.



class zaws_example_002 implementation.
  method if_oo_adt_classrun~main.
    data(method) = `POST`.
    data(service) = `dynamodb`.
    data(host) = `dynamodb.us-west-2.amazonaws.com`.
    data(region) = `us-west-2`.
    data(endpoint) = `https://dynamodb.us-west-2.amazonaws.com`.

    data(content_type) = `application/x-amz-json-1.0`.

    data(amz_target) = `DynamoDB_20120810.CreateTable`.

    data(request_parameters) =
      `{` &
     `"KeySchema": [{"KeyType": "HASH","AttributeName": "Id"}],` &
     `"TableName": "TestTable","AttributeDefinitions": [{"AttributeName": "Id","AttributeType": "S"}],` &
     `"ProvisionedThroughput": {"WriteCapacityUnits": 5,"ReadCapacityUnits": 5}` &
     `}`.

    data(access_key) = ``.
    data(secret_key) = ``.

    zaws_sigv4_utilities=>get_current_timestamp( importing amz_date = data(amz_date)
                                                           datestamp = data(date_stamp) ).

    data(canonical_headers) = zaws_sigv4_utilities=>get_canonical_headers( http_headers = value #(
      ( name = 'content-type' value = content_type )
      ( name = 'host' value = host )
      ( name = 'x-amz-date' value = amz_date )
      ( name = 'x-amz-target' value = amz_target )
    ) ).

    data(signed_headers) = zaws_sigv4_utilities=>get_signed_headers( http_header_names = value #(
      ( name = 'content-type' )
      ( name = 'host' )
      ( name = 'x-amz-date' )
      ( name = 'x-amz-target' )
    ) ).

    data(payload_hash) = zaws_sigv4_utilities=>get_hash( message = request_parameters ).

    data(canonical_request) = zaws_sigv4_utilities=>get_canonical_request(
      http_method = method
      canonical_uri = '/'
      canonical_querystring = ''
      canonical_headers = canonical_headers
      signed_headers = signed_headers
      payload_hash = payload_hash ).

    data(algorithm) = zaws_sigv4_utilities=>get_algorithm( ).

    data(credential_scope) = zaws_sigv4_utilities=>get_credential_scope( datestamp = date_stamp
                                                                         region = region
                                                                         service = service ).

    data(string_to_sign) = zaws_sigv4_utilities=>get_string_to_sign(
      algorithm = algorithm
      amz_date = amz_date
      credential_scope = credential_scope
      canonical_request = canonical_request ).

    data(signing_key) = zaws_sigv4_utilities=>get_signature_key( key = secret_key
                                                                 datestamp = date_stamp
                                                                 region_name = region
                                                                 service_name = service ).

    data(signature) = zaws_sigv4_utilities=>get_signature( signing_key = signing_key
                                                           string_to_sign = string_to_sign ).

    data(credential) = zaws_sigv4_utilities=>get_credential( access_key = access_key
                                                             credential_scope = credential_scope ).

    data(authorization_header) = zaws_sigv4_utilities=>get_authorization_header(
      algorithm = algorithm
      credential = credential
      signature = signature
      signed_headers = signed_headers ).

    try.
        cl_http_client=>create_by_url(
          exporting url = |{ endpoint }|
          importing client = data(http_client)
        ).

        data(rest_client) = new cl_rest_http_client( io_http_client = http_client ).

        rest_client->if_rest_client~set_request_header( iv_name = 'host' iv_value = host ).
        rest_client->if_rest_client~set_request_header( iv_name = 'x-amz-date' iv_value = amz_date ).
        rest_client->if_rest_client~set_request_header( iv_name = 'x-amz-target' iv_value = amz_target ).
        rest_client->if_rest_client~set_request_header( iv_name = 'Authorization' iv_value = authorization_header ).

        data(request) = rest_client->if_rest_client~create_request_entity( ).
        request->set_content_type( iv_media_type = content_type ).
        request->set_binary_data( cl_abap_hmac=>string_to_xstring( request_parameters ) ).

        rest_client->if_rest_client~post( request ).
        data(response) = rest_client->if_rest_client~get_response_entity( ).
        out->write( response->get_string_data(  ) ).

      catch cx_root into data(x_root).
        out->write( x_root->get_text(  ) ).
        out->write( x_root->get_longtext(  ) ).
    endtry.
  endmethod.

endclass.
