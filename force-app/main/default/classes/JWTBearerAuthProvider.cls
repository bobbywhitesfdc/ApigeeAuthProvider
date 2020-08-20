/**
 * Salesforce AuthProvider that uses JWTBearerFlow for Server-to-Server
 * authentication based on Certificates.  No user intervention is required for a 
 * session to be authorized.
 * 
 **/ 
public class JWTBearerAuthProvider extends Auth.AuthProviderPluginClass {
    public static final String RESOURCE_CALLBACK = '/services/authcallback/';
    public static final String CMT_FIELD_CALLBACK_URL = 'Callback_URL__c';
    public static final String CMT_FIELD_PROVIDER_NAME = 'Auth_Provider_Name__c';
    public static final String DUMMY_CODE='9999';
    
    private Map<string,string> config = new Map<string,string>();
    
    public String getCustomMetadataType() {
        return 'JWTBearerAuthProvider__mdt';
    }
    
    /**
     * Construct initial OAuth call to endpoint
     **/ 
    public System.PageReference initiate(Map<String,String> config, String state) {
        System.debug('initiate');
        
        this.config=config;

        final PageReference pageRef = new PageReference(getCallbackUrl(config));
        pageRef.getParameters().put('state',state);
        pageRef.getParameters().put('code',DUMMY_CODE);
        System.debug(pageRef.getUrl());
        return pageRef;

    }
    /**
      This method composes the callback URL automatically UNLESS it has been overridden through Configuration.
      Normally one should not override the callback URL, but it's there in case the generated URL doesn't work.
    **/
    private String getCallbackUrl(Map<string,string> config) {
        // https://{salesforce-hostname}/services/authcallback/{urlsuffix}
        final String overrideUrl = config.get(CMT_FIELD_CALLBACK_URL);
        final String generatedUrl = URL.getSalesforceBaseUrl().toExternalForm() + RESOURCE_CALLBACK + config.get(CMT_FIELD_PROVIDER_NAME);
        return String.isEmpty(overrideUrl) ? generatedUrl : overrideUrl;
    }

    public Auth.AuthProviderTokenResponse handleCallback(Map<String,String> params, Auth.AuthProviderCallbackState state) {
        return null;
    }
    public Auth.UserData getUserInfo(Map<String,String> params, Auth.AuthProviderTokenResponse response) {
        return null;
    }
    private String getAuthToken() {
        Auth.JWT jwt = new Auth.JWT();
        jwt.setSub('user@salesforce.com'); 
        jwt.setAud('https://login.salesforce.com'); 
        jwt.setIss('3MVG99OxTyEMCQ3gNp2PjkqeZKxnmAiG1xV4oHh9AKL_rSK.BoSVPGZHQ​ukXnVjzRgSuQqGn75NL7yfkQcyy7');
        
        //Additional claims to set scope
        Map<String, Object> claims = new Map<String, Object>();
        claims.put('scope', 'api full');
            
        jwt.setAdditionalClaims(claims);

        //Create the object that signs the JWT bearer token
        Auth.JWS jws = new Auth.JWS(jwt, config.get('CertificateName__c '));
        
        //Get the resulting JWS in case debugging is required
        String token = jws.getCompactSerialization();
        
        //Set the token endpoint that the JWT bearer token is posted to
        String tokenEndpoint = config.get('Endpoint__c') + '/services/oauth2/token';
        
        //POST the JWT bearer token
        Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(tokenEndpoint, jws);
 
        //Get the access token
        return bearer.getAccessToken();
    }
}