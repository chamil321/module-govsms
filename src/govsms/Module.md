Send SMS through GovSMS server from Ballerina.

## Module Overview

The GovSms Connector provides the capability to send bulk SMS using Government SMS server using it's SOAP API. 

## Compatibility
|                     |    Version           |
|:-------------------:|:--------------------:|
| Ballerina Language  | 1.2.4                |

## Configurations

Instantiate the connector by giving authentication details in the GovSMS client config, which has built-in support 
for BasicAuth. For the secure connection, secure socket configuration is needed. In addition to that, timeout and 
retry configs also can be configured.

```ballerina
// Create a GovSms client configuration by reading from the config file.
govsms:Configuration govsmsConfig = {
    username: "<GOVSMS_USERNAME>",
    password: "<GOVSMS_PASSWORD>"
};

govsms:Client smsClient = new(govsmsConfig);
```

## Sample

```ballerina
import ballerina/io;
import chamil/govsms;

public function main() {
    govsms:Response|govsms:Error response = smsClient->sendSms("DepartmentCode", "Test message", 
                                                               ["1111111111", "2222222222", "3333333333"]);
    if (response is govsms:Error) {
        io:println("Error: " + response.toString());
    } else {
        io:println("Success : " + response.toString());
    }
}
```
