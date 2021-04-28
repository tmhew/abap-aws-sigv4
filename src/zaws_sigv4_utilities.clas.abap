class zaws_sigv4_utilities definition
  public
  final
  create public .

  public section.
    interfaces if_oo_adt_classrun.

    types: begin of name,
             name type string,
           end of name.

    types: begin of name_value_pair,
             name  type string,
             value type string,
           end of name_value_pair.

    types http_query_parameters type standard table of name_value_pair.
    types http_headers type standard table of name_value_pair.
    types http_header_names type standard table of name.

    constants default_hash_function type string value 'SHA256'.

    class-methods sign importing hash_function         type string default default_hash_function
                                 key                   type xstring
                                 message               type xstring
                       returning value(signed_message) type xstring.

    class-methods get_signature_key importing key                  type string
                                              datestamp            type string
                                              region_name          type string
                                              service_name         type string
                                    returning value(signature_key) type xstring.

    class-methods get_hash importing hash_function         type string default default_hash_function
                                     message               type string
                           returning value(hashed_message) type string.

    class-methods get_current_timestamp exporting amz_date  type string
                                                  datestamp type string.

    class-methods get_canonical_headers importing value(http_headers)      type http_headers
                                        returning value(canonical_headers) type string.

    class-methods get_signed_headers importing value(http_header_names) type http_header_names
                                     returning value(signed_headers)    type string.

    class-methods get_canonical_querystring importing value(http_query_parameters) type http_query_parameters
                                            returning value(canonical_querystring) type string.

    class-methods get_canonical_request importing http_method              type string
                                                  canonical_uri            type string
                                                  canonical_querystring    type string
                                                  canonical_headers        type string
                                                  signed_headers           type string
                                                  payload_hash             type string
                                        returning value(canonical_request) type string.

    class-methods get_credential_scope importing datestamp               type string
                                                 region                  type string
                                                 service                 type string
                                       returning value(credential_scope) type string.

    class-methods get_credential importing access_key        type string
                                           credential_scope  type string
                                 returning value(credential) type string.

    class-methods get_algorithm importing hash_function    type string default default_hash_function
                                returning value(algorithm) type string.

    class-methods get_string_to_sign importing algorithm             type string
                                               amz_date              type string
                                               credential_scope      type string
                                               canonical_request     type string
                                     returning value(string_to_sign) type string.

    class-methods get_signature importing signing_key      type xstring
                                          string_to_sign   type string
                                returning value(signature) type string.

    class-methods get_authorization_header importing algorithm type string
                                                     credential type string
                                                     signed_headers type string
                                                     signature type string
                                           returning value(authorization_header) type string.
  protected section.
  private section.
endclass.



class zaws_sigv4_utilities implementation.
  method sign.
    try.
        cl_abap_hmac=>calculate_hmac_for_raw(
            exporting if_algorithm = hash_function
                      if_key = key
                      if_data = message
            importing ef_hmacxstring = signed_message ).
      catch cx_root.
    endtry.
  endmethod.

  method get_signature_key.
    try.
        data(k_date) = zaws_sigv4_utilities=>sign( key = cl_abap_hmac=>string_to_xstring( |AWS4{ key }| )
                                         message = cl_abap_hmac=>string_to_xstring( datestamp ) ).

        data(k_region) = zaws_sigv4_utilities=>sign( key = k_date
                                           message = cl_abap_hmac=>string_to_xstring( region_name ) ).

        data(k_service) = zaws_sigv4_utilities=>sign( key = k_region
                                            message = cl_abap_hmac=>string_to_xstring( service_name ) ).

        signature_key = zaws_sigv4_utilities=>sign( key = k_service
                                          message = cl_abap_hmac=>string_to_xstring( 'aws4_request' ) ).
      catch cx_root.
    endtry.
  endmethod.

  method get_hash.
    try.
        data(msg_digest) = cl_abap_message_digest=>get_instance( hash_function ).

        msg_digest->digest( exporting if_data = cl_abap_message_digest=>string_to_xstring( message )
                            importing ef_hashstring = hashed_message ).

        hashed_message = to_lower( hashed_message ).

      catch cx_root.
    endtry.
  endmethod.

  method get_current_timestamp.
    get time stamp field data(_timestamp).
    data(timestamp) = conv string( _timestamp ).

    amz_date = |{ timestamp(8) }T{ timestamp+8(6) }Z|.
    datestamp = timestamp(8).
  endmethod.

  method get_canonical_headers.
    loop at http_headers assigning field-symbol(<http_header>).
      <http_header>-name = condense( to_lower( <http_header>-name ) ).
    endloop.

    sort http_headers by name ascending.

    canonical_headers = reduce string(
      init text = ``
      for http_header in http_headers
      next text = |{ text }{ http_header-name }:{ http_header-value }{ cl_abap_char_utilities=>newline }| ).
  endmethod.

  method get_signed_headers.
    loop at http_header_names assigning field-symbol(<name>).
      <name>-name = condense( to_lower( <name>-name ) ).
    endloop.

    sort http_header_names ascending.

    loop at http_header_names into data(name).
      if signed_headers is initial.
        signed_headers = name-name.
      else.
        signed_headers = |{ signed_headers };{ name-name }|.
      endif.
    endloop.
  endmethod.

  method get_canonical_querystring.
    sort http_query_parameters by name ascending.

    loop at http_query_parameters into data(query_parameter).
      query_parameter-value = cl_http_utility=>if_http_utility~escape_url( query_parameter-value ).
      replace all occurrences of '%2f' in query_parameter-value with '%2F'.

      if canonical_querystring is initial.
        canonical_querystring = |{ query_parameter-name }={ query_parameter-value }|.
      else.
        canonical_querystring = |{ canonical_querystring }&{ query_parameter-name }={ query_parameter-value }|.
      endif.
    endloop.
  endmethod.

  method get_canonical_request.
    canonical_request = |{ http_method }| &
                        |{ cl_abap_char_utilities=>newline }| &
                        |{ canonical_uri }| &
                        |{ cl_abap_char_utilities=>newline }| &
                        |{ canonical_querystring }| &
                        |{ cl_abap_char_utilities=>newline }| &
                        |{ canonical_headers }| &
                        |{ cl_abap_char_utilities=>newline }| &
                        |{ signed_headers }| &
                        |{ cl_abap_char_utilities=>newline }| &
                        |{ payload_hash }|.
  endmethod.

  method get_credential_scope.
    credential_scope = |{ datestamp }/{ region }/{ service }/aws4_request|.
  endmethod.

  method get_credential.
    credential = |{ access_key }/{ credential_scope }|.
  endmethod.

  method get_algorithm.
    algorithm = |AWS4-HMAC-{ hash_function }|.
  endmethod.

  method get_string_to_sign.
    string_to_sign = |{ algorithm }| &
                     |{ cl_abap_char_utilities=>newline }| &
                     |{ amz_date }| &
                     |{ cl_abap_char_utilities=>newline }| &
                     |{ credential_scope }| &
                     |{ cl_abap_char_utilities=>newline }| &
                     |{ get_hash( message = canonical_request ) }|.
  endmethod.

  method get_signature.
    try.
        signature = |{ sign( key = signing_key
                       message = cl_abap_hmac=>string_to_xstring( string_to_sign ) ) }|.

        signature = to_lower( signature ).

      catch cx_root.
    endtry.
  endmethod.

  method get_authorization_header.
    authorization_header = |{ algorithm } Credential={ credential }, SignedHeaders={ signed_headers }, Signature={ signature }|.
  endmethod.

  method if_oo_adt_classrun~main.
    data(canonical_headers) = zaws_sigv4_utilities=>get_signed_headers( http_header_names = value #(
        ( name = `x-amz-date` )
        ( name = `Host` )
    ) ).

    out->write( |{ canonical_headers }x| ).
  endmethod.
endclass.
