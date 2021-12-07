# AWS Signature V4 for ABAP

Wanted to extend to AWS but there isn't AWS SDK for ABAP? Now, you can call AWS API directly with AWS Signature v4 authentication. 

This implementation is based on AWS documentation [Signature Version 4 signing process](https://docs.aws.amazon.com/general/latest/gr/signature-version-4.html). You can look at [ZAWS_SIGV4_UTILITIES](src/zaws_sigv4_utilities.clas.abap) for implementation details and the following examples for usages. You will need to provide AWS access and secret keys to run the examples.
 
|Example         |Documentation|
|----------------|-------------|
|[ZAWS_SIGV4_EXAMPLE_001](src/zaws_sigv4_example_001.clas.abap)|[Using GET with an authorization header](https://docs.aws.amazon.com/general/latest/gr/sigv4-signed-request-examples.html#sig-v4-examples-get-auth-header)
|[ZAWS_SIGV4_EXAMPLE_002](src/zaws_sigv4_example_002.clas.abap)|[Using POST](https://docs.aws.amazon.com/general/latest/gr/sigv4-signed-request-examples.html#sig-v4-examples-post)
|[ZAWS_SIGV4_EXAMPLE_003](src/zaws_sigv4_example_003.clas.abap)|[Using GET with authentication information in the Query string](https://docs.aws.amazon.com/general/latest/gr/sigv4-signed-request-examples.html#sig-v4-examples-get-query-string)

Refers to [AWS Documentation](https://docs.aws.amazon.com/index.html) for the list of APIs that you can use. You might want to import the relevant certificates to `STRUST` if you are making a call to a HTTPS endpoint. Below is an example on how to retrieve the certificates for a HTTPS endpoint.

```bash
 openssl s_client -connect ec2.amazonaws.com:443 -showcerts
```

## Misc

+ [ABAP SDK for Azure](https://github.com/microsoft/ABAP-SDK-for-Azure)
+ [Azure - Components of a REST API request/response](https://docs.microsoft.com/en-us/rest/api/azure/#components-of-a-rest-api-requestresponse)
+ [Access Google APIs using the OAuth 2.0 Client API](https://wiki.scn.sap.com/wiki/display/Security/Access+Google+APIs+using+the+OAuth+2.0+Client+API)
