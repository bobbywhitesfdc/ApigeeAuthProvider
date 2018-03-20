@IsTest(isParallel=true)
public class ApigeeAuthProviderTest {
        public static final String CONTENT_TYPE_HEADER = 'Content-Type';
        public static final String CONTENT_TYPE_JSON = 'application/json';
    	private static final String ACCESS_TOKEN = 'gv6iCx48OaH76ufiGXBUlRTRTXxx';
   	 	private static final String EXPIRES_IN = '123';
        private static final String STATE = 'mocktestState'; 
        private static final String TOKEN_TYPE = 'Bearer'; 
        
        private static final String PROVIDER_NAME = 'UnitTestProvider'; 
        
   	 	private static final String CALLBACK_URL_OVERRIDE = 
        System.URL.getSalesforceBaseUrl().getHost()+'/services/authcallback/' + PROVIDER_NAME; 
    
        private static final String TEST_USER_EMAIL = 'developer@example.com';
        private static final String KEY = 'testKey'; 
        private static final String SECRET = 'testSecret'; 
    	private static final String SCOPE = 'View';
    
        private static final String STATE_TO_PROPOGATE = 'testState'; 
        private static final String ACCESS_TOKEN_URL = 
        'http://www.dummyhost.com/accessTokenUri';
        private static final String EMPTY_VALUE = ''; 

        private static final String jsonGoodToken = '{'+
        '  \"refresh_token_expires_in\" : \"0\",'+
        '  \"api_product_list\" : \"[helloworld, HelloWorld_OAuth2-Product]\",'+
        '  \"api_product_list_json\" : [ \"helloworld\", \"HelloWorld_OAuth2-Product\" ],'+
        '  \"organization_name\" : \"bobbywhite-eval\",'+
        '  \"developer.email\" : \"developer@example.com\",'+
        '  \"token_type\" : \"Bearer\",'+
        '  \"issued_at\" : \"1521077832490\",'+
        '  \"client_id\" : \"testKey\",'+
        '  \"access_token\" : \"gv6iCx48OaH76ufiGXBUlRTRTXxx\",'+
        '  \"application_name\" : \"47bc6c8d-34f3-4141-b9e6-f1679a8240e7\",'+
        '  \"scope\" : \"\",'+
        '  \"expires_in\" : \"3599\",'+
        '  \"refresh_count\" : \"0\",'+
        '  \"status\" : \"approved\"'+
        '}';
        private static final String jsonError1 = '{\"fault\":{\"faultstring\":\"Invalid client identifier {0}\",\"detail\":{\"errorcode\":\"oauth.v2.InvalidClientIdentifier\"}}}';
        private static final String jsonError2 = '{\"ErrorCode\" : \"invalid_client\", \"Error\" :\"Client credentials are invalid\"}';

        private static final String jsonBadQueryParam = '{\"fault\":{\"faultstring\":\"Unresolved variable : request.header.Authorization\",\"detail\":{\"errorcode\":\"steps.basicauthentication.UnresolvedVariable\"}}}';

    
    private static Map<String,String> setupAuthProviderConfig () 
    { 
        final Map<String,String> authProviderConfiguration = new Map<String,String>(); 
        authProviderConfiguration.put(ApigeeAuthProvider.CMT_FIELD_PROVIDER_NAME, PROVIDER_NAME); 
        authProviderConfiguration.put(ApigeeAuthProvider.CMT_FIELD_AUTHTOKEN_URL, ACCESS_TOKEN_URL); 
        authProviderConfiguration.put(ApigeeAuthProvider.CMT_FIELD_CALLBACK_URL, EMPTY_VALUE); 
        authProviderConfiguration.put(ApigeeAuthProvider.CMT_FIELD_CLIENT_ID, KEY); 
        authProviderConfiguration.put(ApigeeAuthProvider.CMT_FIELD_CLIENT_SECRET,SECRET); 
        authProviderConfiguration.put(ApigeeAuthProvider.CMT_FIELD_SCOPE,SCOPE);
        authProviderConfiguration.put(ApigeeAuthProvider.CMT_FIELD_USE_JSON,'False');        
       
        return authProviderConfiguration; 
    
    } 
    
    static testMethod void testMetadataType()
    {
        final ApigeeAuthProvider provider = new ApigeeAuthProvider(); 
        final String actual = provider.getCustomMetadataType();
        final String expected = ApigeeAuthProvider.CUSTOM_MDT_NAME;
        System.assertEquals(expected, actual);
        
    }
    
    static testMethod void testInitiateMethod()
    {
        final Map<String,String> authProviderConfiguration = setupAuthProviderConfig(); 
        final ApigeeAuthProvider provider = new ApigeeAuthProvider(); 
        
        final PageReference expectedUrl = new PageReference(authProviderConfiguration.get('Callback_URL__c'));
        expectedUrl.getParameters().put('state',STATE_TO_PROPOGATE);

        final PageReference actualUrl = provider.initiate(authProviderConfiguration, STATE_TO_PROPOGATE); 
        System.assertEquals(expectedUrl.getParameters().get('state'), actualUrl.getParameters().get('state'));
   
    }
    
    static testMethod void testHandleCallback() 
    { 
        final Map<String,String> authProviderConfiguration = setupAuthProviderConfig(); 
       	final ApigeeAuthProvider provider = new ApigeeAuthProvider(); 
        
        Test.setMock(HttpCalloutMock.class, new ApigeeMockService(jsonGoodToken,200)); 
    
        final Map<String,String> queryParams = new Map<String,String>(); 
        queryParams.put('code','code'); 
        queryParams.put('state',STATE); 
        
        final Auth.AuthProviderCallbackState cbState = new Auth.AuthProviderCallbackState(null,null,queryParams); 
        
        final Auth.AuthProviderTokenResponse actualAuthProvResponse = provider.handleCallback(authProviderConfiguration, cbState); 
        
        final Auth.AuthProviderTokenResponse expectedAuthProvResponse = new Auth.AuthProviderTokenResponse(PROVIDER_NAME, ACCESS_TOKEN, SECRET, STATE); 
    
        System.assertEquals(expectedAuthProvResponse.provider, actualAuthProvResponse.provider); 
        System.assertEquals(expectedAuthProvResponse.oauthToken, actualAuthProvResponse.oauthToken); 
        System.assertEquals(expectedAuthProvResponse.oauthSecretOrRefreshToken, actualAuthProvResponse.oauthSecretOrRefreshToken); 
        System.assertEquals(expectedAuthProvResponse.state, actualAuthProvResponse.state); 

    }

    static testMethod void testHandleCallbackJson() 
    { 
        final Map<String,String> authProviderConfiguration = setupAuthProviderConfig();
        // override the USE_JSON config
        authProviderConfiguration.put(ApigeeAuthProvider.CMT_FIELD_USE_JSON,'True');

        final ApigeeAuthProvider provider = new ApigeeAuthProvider(); 
        
        Test.setMock(HttpCalloutMock.class, new ApigeeMockService(jsonGoodToken,200)); 
    
        final Map<String,String> queryParams = new Map<String,String>(); 
        queryParams.put('code','code'); 
        queryParams.put('state',STATE); 
        
        final Auth.AuthProviderCallbackState cbState = new Auth.AuthProviderCallbackState(null,null,queryParams); 
        
        final Auth.AuthProviderTokenResponse actualAuthProvResponse = provider.handleCallback(authProviderConfiguration, cbState); 
        
        final Auth.AuthProviderTokenResponse expectedAuthProvResponse = new Auth.AuthProviderTokenResponse(PROVIDER_NAME, ACCESS_TOKEN, SECRET, STATE); 
    
        System.assertEquals(expectedAuthProvResponse.provider, actualAuthProvResponse.provider); 
        System.assertEquals(expectedAuthProvResponse.oauthToken, actualAuthProvResponse.oauthToken); 
        System.assertEquals(expectedAuthProvResponse.oauthSecretOrRefreshToken, actualAuthProvResponse.oauthSecretOrRefreshToken); 
        System.assertEquals(expectedAuthProvResponse.state, actualAuthProvResponse.state); 

    }

    static testMethod void testHandleCallbackError1() 
    { 
        final Map<String,String> authProviderConfiguration = setupAuthProviderConfig(); 
        final ApigeeAuthProvider provider = new ApigeeAuthProvider(); 
        
        Test.setMock(HttpCalloutMock.class, new ApigeeMockService(jsonError1,401)); 
    
        final Map<String,String> queryParams = new Map<String,String>(); 
        queryParams.put('code','code'); 
        queryParams.put('state',STATE); 
        
        final Auth.AuthProviderCallbackState cbState = new Auth.AuthProviderCallbackState(null,null,queryParams); 
        
        try {
            final Auth.AuthProviderTokenResponse actualAuthProvResponse = provider.handleCallback(authProviderConfiguration, cbState); 
            System.Assert(false,'Should throw an Exception on bad http return code!');
        } catch (ApigeeAuthProvider.TokenException ex) {
            System.AssertEquals('Invalid client identifier oauth.v2.InvalidClientIdentifier',ex.getMessage());
        }
    }

    static testMethod void testHandleCallbackError2() 
    { 
        final Map<String,String> authProviderConfiguration = setupAuthProviderConfig(); 
        final ApigeeAuthProvider provider = new ApigeeAuthProvider(); 
        
        Test.setMock(HttpCalloutMock.class, new ApigeeMockService(jsonError2,401)); 
    
        final Map<String,String> queryParams = new Map<String,String>(); 
        queryParams.put('code','code'); 
        queryParams.put('state',STATE); 
        
        final Auth.AuthProviderCallbackState cbState = new Auth.AuthProviderCallbackState(null,null,queryParams); 
        
        try {
            final Auth.AuthProviderTokenResponse actualAuthProvResponse = provider.handleCallback(authProviderConfiguration, cbState); 
            System.Assert(false,'Should throw an Exception on bad http return code!');
        } catch (ApigeeAuthProvider.TokenException ex) {
            System.AssertEquals('invalid_client',ex.getMessage());
        }
    } 

    static testMethod void testRefresh() {

        final Map<String,String> config = setupAuthProviderConfig(); 
        final ApigeeAuthProvider provider = new ApigeeAuthProvider(); 
        
        Test.setMock(HttpCalloutMock.class, new ApigeeMockService(jsonGoodToken,200)); 

        final Auth.OAuthRefreshResult actual = provider.refresh(config,'myUnusedRefreshToken');        
    
        final Auth.OAuthRefreshResult expected = new Auth.OAuthRefreshResult(ACCESS_TOKEN, TOKEN_TYPE); 
    
        System.assertEquals(expected.accessToken, actual.accessToken); 
        System.assertEquals(expected.refreshToken, actual.refreshToken); 
        System.assertEquals(expected.error,actual.error);


    } 
    
    static testMethod void testGetUserInfo() 
    { 
        Map<String,String> authProviderConfiguration = setupAuthProviderConfig(); 
        ApigeeAuthProvider provider = new ApigeeAuthProvider(); 
    
        Test.setMock(HttpCalloutMock.class, new ApigeeMockService(jsonGoodToken,200)); 
    
        Auth.AuthProviderTokenResponse response = new Auth.AuthProviderTokenResponse(PROVIDER_NAME, ACCESS_TOKEN ,'sampleOauthSecret', STATE); 
        Auth.UserData actualUserData = provider.getUserInfo(authProviderConfiguration, response) ; 
    
        Map<String,String> provMap = new Map<String,String>(); 
        provMap.put('key1', 'value1'); 
        provMap.put('key2', 'value2'); 
    
        final Auth.UserData expectedUserData = new Auth.UserData(
              null // identifier
            , null // firstName
            , null // lastName
            , null  // fullName
            , TEST_USER_EMAIL // email
            , null // link
            , TEST_USER_EMAIL // userNAme
            , null  // locale
            , PROVIDER_NAME  // provider
            , null // siteLoginUrl
            , new Map<String,String>()); 
    
        System.assertNotEquals(actualUserData,null); 
        System.assertEquals(expectedUserData.firstName, actualUserData.firstName); 
        System.assertEquals(expectedUserData.lastName, actualUserData.lastName); 
        System.assertEquals(expectedUserData.fullName, actualUserData.fullName); 
        System.assertEquals(expectedUserData.email, actualUserData.email); 
        System.assertEquals(expectedUserData.username, actualUserData.username); 
        System.assertEquals(expectedUserData.locale, actualUserData.locale); 
        System.assertEquals(expectedUserData.provider, actualUserData.provider); 
        System.assertEquals(expectedUserData.siteLoginUrl, actualUserData.siteLoginUrl); 
    } 

    static testmethod void testEncodingAsJSON() {
        final Map<String,String> config = setupAuthProviderConfig();

        final String output = new ApigeeAuthProvider().encodeParameters(config,ApigeeAuthProvider.ENCODING_JSON);
        System.debug('encoded jSON: ' + output);

        // Assert that we deserialize parse the output as JSON
        Map<String,Object> result = (Map<String,Object>)JSON.deserializeUntyped(output);
 
        System.AssertEquals('client_credentials',(String)result.get(ApigeeAuthProvider.GRANT_TYPE_PARAM),'Grant type did not match');
        System.AssertEquals(KEY,(String)result.get(ApigeeAuthProvider.CLIENT_ID_PARAM),'Client key did not match');
        System.AssertEquals(SECRET,(String)result.get(ApigeeAuthProvider.CLIENT_SECRET_PARAM),'Client secret did not match');
        System.AssertEquals(SCOPE,(String)result.get(ApigeeAuthProvider.SCOPE_PARAM),'Scope did not match');
    }

    static testmethod void testTokenMembers() {
        ApigeeAuthProvider.TokenResponse resp = (ApigeeAuthProvider.TokenResponse) JSON.deserialize(jsonGoodToken, ApigeeAuthProvider.TokenResponse.class);

        System.AssertEquals('testKey',resp.client_id);
        System.AssertEquals('0',resp.refresh_token_expires_in);
        System.AssertEquals('[helloworld, HelloWorld_OAuth2-Product]',resp.api_product_list);
        System.AssertEquals(2,resp.api_product_list_json.size());
        System.AssertEquals('bobbywhite-eval',resp.organization_name);
        //System.AssertEquals('developer@example.com',resp.developer_email);
        System.AssertEquals('Bearer',resp.token_type);
        System.AssertEquals('1521077832490',resp.issued_at);
        System.AssertEquals('gv6iCx48OaH76ufiGXBUlRTRTXxx',resp.access_token);
        System.AssertEquals('47bc6c8d-34f3-4141-b9e6-f1679a8240e7',resp.application_name);
        System.AssertEquals('',resp.scope);
        System.AssertEquals('3599',resp.expires_in);
        System.AssertEquals('0',resp.refresh_count);
        System.AssertEquals('approved',resp.status); 
    }

    static testmethod void testErrorBad() {
        ApigeeAuthProvider.TokenResponse resp = (ApigeeAuthProvider.TokenResponse) JSON.deserialize(jsonGoodToken, ApigeeAuthProvider.TokenResponse.class);
        System.AssertEquals(null,resp.getErrorMessage());
    }
    
     
    // Implement a mock http response generator for Apigee. 
    public class ApigeeMockService implements HttpCalloutMock 
    {
        String jsonResponse;
        Integer httpCode;

        public ApigeeMockService(String json, Integer code) {
            this.jsonResponse=json;
            this.httpCode=code;
        }

        public HTTPResponse respond(HTTPRequest req) 
        { 
            if (req.getHeader(CONTENT_TYPE_HEADER)==CONTENT_TYPE_JSON) {
                // Check for Query Parameters on the Endpoint URL and if any are found, return a server error
                final PageReference endpoint = new PageReference(req.getEndpoint());
                if (endpoint.getParameters().size() > 0) {
                    this.httpCode=500;
                    this.jsonResponse= jsonBadQueryParam;
                }
            }
            // Create the response 
            HttpResponse res = new HttpResponse(); 
            res.setHeader(CONTENT_TYPE_HEADER, CONTENT_TYPE_JSON); 
            res.setBody(jsonResponse); 
            res.setStatusCode(this.httpCode); 
            return res; 
        } 
    }
    
}