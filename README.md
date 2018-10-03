# SFDX  App<br/>
ApigeeAuthProvider<br/>

## Dev -- Deploy to Scratch Org<br/> 

sfdx force:org:create -f config/project-scratch-def.json -a MyScratchOrg<br/>
sfdx force:source:push -u MyScratchOrg<br/>

## Dev -- Deploy to Sandbox<br/> 
sfdx force:source:convert -d temp/ --packagename ApigeeAuthProvider<br/>
sfdx force:mdapi:deploy -d temp/ -u "sandbox_username" -l RunSpecifiedTests -r ApigeeAuthProviderTest<br/>

## Resources


## Description of Files and Directories


## Issues


