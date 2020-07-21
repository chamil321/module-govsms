// Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;
import ballerina/log;

public type Client client object {

    private http:Client govSmsClient;
    private string username;
    private string password;

    public function __init(Configuration config) {
        self.username = config.username;
        self.password = config.password;

        http:ClientConfiguration httpClientConfig = {
            secureSocket: config?.secureSocketConfig,
            timeoutInMillis: config.timeoutInMillis,
            retryConfig: config?.retryConfig
        };

        self.govSmsClient = new(SECURE_BASE_URL, httpClientConfig);
    }

    # Send SMS to the recipient.
    #
    # + subject - The title that should appear in the SMS. Either source mobile or department code
    # + message - The message body of the SMS
    # + recepient - The mobile number which the SMS should be delivered to
    # + return - The `govsms:Error` if it is a failure or else the response
    public remote function sendSms(string subject, string message, string recepient) returns @tainted Response|Error {
        xml payload = xml `<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
                            xmlns:v1="http://schemas.icta.lk/xsd/kannel/handler/v1/"
                            soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
                              <soapenv:Header>
                                 <govsms:authData xmlns:govsms="http://govsms.icta.lk/">
                                    <govsms:user>${self.username}</govsms:user>
                                    <govsms:key>${self.password}</govsms:key>
                                 </govsms:authData>
                              </soapenv:Header>
                              <soapenv:Body>
                                 <v1:SMSRequest>
                                    <v1:requestData>
                                       <v1:outSms>${message}</v1:outSms>
                                       <v1:recepient>${recepient}</v1:recepient>
                                       <v1:depCode>${subject}</v1:depCode>
                                       <v1:smscId />
                                       <v1:billable />
                                    </v1:requestData>
                                 </v1:SMSRequest>
                              </soapenv:Body>
                           </soapenv:Envelope>`;

        http:Request request = new;
        request.setXmlPayload(payload, contentType = "text/xml");
        request.setHeader("SOAPAction", "urn:mediate");
        var result = self.govSmsClient->post("", request);

        if result is error {
            error err = result;
            return Error(message = "Message sending failed", cause = err, stuatusCode = 500);
        }

        http:Response response = <http:Response> result;
        var resPayload = response.getXmlPayload();
        if (resPayload is error) {
            log:printDebug(function () returns string {
                                return "Invalid payload content: " + resPayload.toString();
                            });
            return Error(message = "Invalid payload content", cause = resPayload, stuatusCode = 500);
        }

        xml xmlPayload = <xml> resPayload;
        log:printDebug(function () returns string {
                            return "XML payload : " + xmlPayload.toString();
                        });

        if (response.statusCode == 200) {
            xmlns "http://schemas.icta.lk/xsd/kannel/handler/v1/" as ns1;
            xml xmlMessage = xmlPayload/**/<ns1:ackMessage>/*;
            return { statusCode : response.statusCode, message : xmlMessage.toString() };
        }

        //Process error response
        xml xmlMessage = xmlPayload/**/<faultstring>/*;
        return Error(message = xmlMessage.toString(), stuatusCode = response.statusCode);
    }
};