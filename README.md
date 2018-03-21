# SFDX  App
ApigeeAuthProvider

## Dev -- Deploy to Scratch Org 

sfdx force:org:create -f config/project-scratch-def.json -a MyScratchOrg
sfdx force:source:push -u MyScratchOrg

## Dev -- Deploy to Sandbox 
sfdx force:source:convert -d temp/ --packagename ApigeeAuthProvider
sfdx force:mdapi:deploy -d temp/ -u "sandbox_username" -l RunSpecifiedTests -r ApigeeAuthProviderTest 

## Resources


## Description of Files and Directories


## Issues


