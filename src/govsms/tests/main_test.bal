import ballerina/config;
import ballerina/system;
import ballerina/test;
import ballerina/time;

string username = system:getEnv("GOVSMS_USERNAME") == "" ? config:getAsString("GOVSMS_USERNAME") : system:getEnv
                  ("GOVSMS_USERNAME");
string password = system:getEnv("GOVSMS_PASSWORD") == "" ? config:getAsString("GOVSMS_PASSWORD") : system:getEnv
                  ("GOVSMS_PASSWORD");

Configuration govsmsClearTextConfig = {
    username : username,
    password : password
};

Client govsmsClearTextClient = new(govsmsClearTextConfig);

@test:Config {}
function testClearTextClient() {
    Response|Error response = govsmsClearTextClient->sendSms("IctaTest", "Test cleartext message : " + getTimestamp(),
                                                             ["0716181154"]);
    if (response is Error) {
    	 test:assertFail(msg = "Message sending failed " + response.toString());
    } else {
    	 test:assertEquals(response.statusCode, 200, msg = "Mismatched status code");
    }
}

Configuration govsmsSecureConfig = {
    username : username,
    password : password,
    secureSocketConfig: {
            keyStore: {
                path: config:getAsString("b7a.home") +
                    "/bre/security/ballerinaKeystore.p12",
                password: "ballerina"
            }
        }
};

Client govsmsSecureClient = new(govsmsSecureConfig);

@test:Config {}
function testSecureClient() {
    Response|Error response = govsmsSecureClient->sendSms("IctaTest", "Test secure message : " + getTimestamp(),
                                                          ["0716181154"]);
    if (response is Error) {
    	 test:assertFail(msg = "Message sending failed " + response.toString());
    } else {
    	 test:assertEquals(response.statusCode, 200, msg = "Mismatched status code");
    }
}

function getTimestamp() returns string {
    return time:toString(time:currentTime());
}

Configuration authenticationConfig = {
    username : username,
    password : "password"

};

Client govsmsAuthTestClient = new(authenticationConfig);

@test:Config {}
function testAuthenticationFailure() {
    Response|Error response = govsmsAuthTestClient->sendSms("IctaTest", "Test authentication : " + getTimestamp(),
                                                             ["0716181154"]);
    if (response is Error) {
    	 test:assertEquals(<string> response.detail()?.message, "Invalid Authentication Key");
    } else {
    	 test:assertFail(msg = "Authentication flow malfunctioned. " + response.toString());
    }
}
