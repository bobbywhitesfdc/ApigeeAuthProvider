public class JWTConnectBasic {
    public static void getToken(){
        
        httpRequest jwtAuth = new HttpRequest();
        
        String username = 'salesforcebasic';
        String password = 'salesforcebasic';
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' +
            EncodingUtil.base64Encode(headerValue);
        jwtAuth.setHeader('Authorization', authorizationHeader);
        
        // jwtAuth.setHeader('Authorization', 'Basic c2FsZXNmb3JjZWJhc2ljOnNhbGVzZm9yY2ViYXNpYw==');  
        
        jwtAuth.setHeader('Content-Type','application/x-www-form-urlencoded');
        // jwtAuth.setHeader('Cookie','JSESSIONID=jlJFtUNzb2uDdiGMfgjpbq8meJOcFrAbXTUGuUSw.tlaccmanapp1; TS019f544c=0154ce24993bc5f98019ed1b149475b3184f33616c8b66b67a768dc66383ee343f10a9ff860ac2f7bff1463dca7d03f6d747f009f195a1b590cb5af3ad91b854294ac8f154; _ga=GA1.3.1841220218.1592407799; _gcl_au=1.1.173608628.1592415617; _fbp=fb.2.1592415617625.1427618416; _ga=GA1.4.1841220218.1592407799; BPSyncStatus=sync; dd_opener_domain=ccstore-dev-zepa.oracleoutsourcing.com; _gid=GA1.3.1488511402.1593028014; i18next=es; dd_sync=test; _uetsid=3848641a-2f37-5893-c2f6-bd98f0ba7624; _uetvid=7666e627-3d2f-db72-2b1d-0bf93e42af79; manualLinkerCID=2.245181445.1488511402.1593028014-1841220218.1592407799; _hjid=cc010f32-b655-4420-80fb-5cc0555f475a; amlbcookie=01; iPlanetDirectoryPro=sFtwR6uTJlDGbnHsjDhb63sM2Gg.*AAJTSQACMDIAAlNLABwxL3lVOFhzMFU1YWVyZVArYXZSZ1FHY21OelE9AAJTMQACMDE.*; TS019fc7a5=0154ce249961a5856c6310284bc035c2bb017bcd3c82ba6488a47bbb5f9cd3ef63d2175fd70369886f22230db9842262168dca1c61c2197d9c55e572d13cc531b6671d4eac287d99d9dc11e0e80ec9054574a4e5ac');
        
        jwtAuth.setBody('grant_type=client_credentials');
        
        jwtAuth.setMethod('POST');
        jwtAuth.setEndPoint('https://sesiont.telecom.com.ar/openam/oauth2/access_token?realm=/authappext');
        
        Http auth = new Http();
        
        HTTPResponse authResponse = auth.send(jwtAuth);
        System.debug('JWT:'+authResponse.getBody());
        
        if(authResponse.getStatusCode() == 200) {
            String idToken;
            JSONParser parser = JSON.createParser(authResponse.getBody());
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'id_token')) {
                    // Move to the value.
                    parser.nextToken();
                    // Return the access_token
                    idToken = parser.getText();
                    System.debug('Id Token ['+idToken.length()+']:'+idToken);
                }
            }
            
            httpRequest restAPI = new HttpRequest();
            restAPI.setHeader('Authorization', 'Bearer '+ idToken);
            restAPI.setEndpoint('https://dxpt.telecom.com.ar/OutageMiddleware/v1/outages/addressoutage/6e42e-e633d-97403-7ee5b-2dd5?dateFrom=2020-04-03&dateTo=2020-04-04');
            restAPI.setMethod('GET');
            Http http = new Http();
            
            HTTPResponse httpResponse = http.send(restAPI);
            System.debug('HTTPResponse:'+httpResponse.getBody());
        }
    }
}