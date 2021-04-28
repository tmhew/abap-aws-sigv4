class zaws_example_003 definition
  public
  final
  create public .

  public section.
    interfaces if_oo_adt_classrun.

  protected section.
  private section.

endclass.



class zaws_example_003 implementation.
  method if_oo_adt_classrun~main.
    data(method) = `GET`.
    data(service) = `iam`.
    data(host) = `iam.amazonaws.com`.
    data(region) = `us-east-1`.
    data(endpoint) = `https://iam.amazonaws.com`.

    data(access_key) = ``.
    data(secret_key) = ``.

    zaws_sigv4_utilities=>get_current_timestamp( importing amz_date = data(amzdate)
                                                           datestamp = data(datestamp) ).

    data(canonical_headers) = zaws_sigv4_utilities=>get_canonical_headers( http_headers = value #(
      ( name = 'host' value = host )
    ) ).

    data(signed_headers) = zaws_sigv4_utilities=>get_signed_headers( http_header_names = value #( ( name = 'host' ) ) ).

    data(algorithm) = zaws_sigv4_utilities=>get_algorithm( ).

    data(credential_scope) = zaws_sigv4_utilities=>get_credential_scope( datestamp = datestamp
                                                                         region = region
                                                                         service = service ).

    data(credential) = zaws_sigv4_utilities=>get_credential( access_key = access_key
                                                             credential_scope = credential_scope ).

    data(canonical_querystring) = zaws_sigv4_utilities=>get_canonical_querystring( http_query_parameters = value #(
      ( name = 'Action' value = 'CreateUser' )
      ( name = 'UserName' value = 'NewUser' )
      ( name = 'Version' value = '2010-05-08' )
      ( name = 'X-Amz-Algorithm' value = algorithm )
      ( name = 'X-Amz-Credential' value = credential )
      ( name = 'X-Amz-Date' value = amzdate )
      ( name = 'X-Amz-Expires' value = 30 )
      ( name = 'X-Amz-SignedHeaders' value = signed_headers )
    ) ).

    data(payload_hash) = zaws_sigv4_utilities=>get_hash( message = '' ).

    data(canonical_request) = zaws_sigv4_utilities=>get_canonical_request(
      canonical_headers = canonical_headers
      canonical_querystring = canonical_querystring
      canonical_uri = '/'
      http_method = method
      payload_hash = payload_hash
      signed_headers = signed_headers
    ).

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

    canonical_querystring = |{ canonical_querystring }&X-Amz-Signature={ to_lower( signature ) }|.

    data(request_url) = |{ endpoint }?{ canonical_querystring }|.

    try.
        cl_http_client=>create_by_url(
          exporting url = request_url
          importing client = data(http_client)
        ).

        data(rest_client) = new cl_rest_http_client( io_http_client = http_client ).

        rest_client->if_rest_client~get( ).
        data(response) = rest_client->if_rest_client~get_response_entity( ).
        out->write( response->get_string_data(  ) ).

      catch cx_root into data(x_root).
        out->write( x_root->get_text(  ) ).
        out->write( x_root->get_longtext(  ) ).
    endtry.
  endmethod.

endclass.
