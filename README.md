<a href="https://githubsfdeploy.herokuapp.com?owner=bobbywhitesfdc&repo=ApigeeAuthProvider">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>
<br/>
# SFDX  App<br/>
ApigeeAuthProvider<br/>

## Dev -- Deploy to Scratch Org<br/> 

sfdx force:org:create -f config/project-scratch-def.json -a MyScratchOrg<br/>
sfdx force:source:push -u MyScratchOrg<br/>

## Dev -- Deploy to Sandbox<br/> 
sfdx force:source:convert -d temp/ --packagename ApigeeAuthProvider<br/>
sfdx force:mdapi:deploy -d temp/ -u "sandbox_username" -l RunSpecifiedTests -r ApigeeAuthProviderTest<br/>


## FAQ
When configuring the AuthProvider, make sure that you set Name and URL Suffix to the same value!  If you don't then you must override the Callback URL.  See https://github.com/bobbywhitesfdc/ApigeeAuthProvider/issues/1


