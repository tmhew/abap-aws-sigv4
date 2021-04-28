# AWS Signature V4 (ABAP)

The implementation is based on AWS documentation [Signature Version 4 signing process](https://docs.aws.amazon.com/general/latest/gr/signature-version-4.html). You can look at `ZAWS_SIGV4_UTILITIES` for implementation details and `ZAWS_EXAMPLE_*` for usages. 
 
|Example         |Documentation|
|----------------|-------------|
|[ZAWS_EXAMPLE_001](src/zaws_example_001.clas.abap)|[Using GET with an authorization header (Python)](https://docs.aws.amazon.com/general/latest/gr/sigv4-signed-request-examples.html#sig-v4-examples-get-auth-header)
|[ZAWS_EXAMPLE_002](src/zaws_example_002.clas.abap)|[Using POST (Python)](https://docs.aws.amazon.com/general/latest/gr/sigv4-signed-request-examples.html#sig-v4-examples-post)
|[ZAWS_EXAMPLE_003](src/zaws_example_003.clas.abap)|[Using GET with authentication information in the Query string (Python)](https://docs.aws.amazon.com/general/latest/gr/sigv4-signed-request-examples.html#sig-v4-examples-get-query-string)
