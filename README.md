# GovSms Connector

The GovSms Connector provides the capability to send SMS using Government SMS server using it's SOAP API. 

## Compatibility
|                     |    Version           |
|:-------------------:|:--------------------:|
| Ballerina Language  | 1.2.4                |

## Configurations

Instantiate the connector by giving authentication details in the GovSMS client config, which has built-in support 
for BasicAuth. For the secure connection, secure socket configuration is needed. In addtion to that, timeout and 
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
    govsms:Response|govsms:Error response = smsClient->sendSms("DepartmentCode", "Test message", "0777777777");
    if (response is govsms:Error) {
        io:println("Error: " + response.toString());
    } else {
        io:println("Success : " + response.toString());
    }
}
```
