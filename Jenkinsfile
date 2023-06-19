def performsfsDeployment(String share) {
    stage("${share}") {
        echo "Building the ${share}"
		echo "${nexusversion}"
		sh "sh rmindex.sh"
		sh "rsync -avh ${share} intershop1@${share}:/opt/intershop/install/new_workspace"
		sh "ssh -t intershop1@${share} ASSEMBLY=${nexusversion} sh /opt/intershop/install/new_workspace/${share}/deploy.sh"
        }
    
}

def performAppserverDeployment(String appservers) {
    stage("${appservers}") {
        echo "Building the ${appservers}"
		echo "${nexusversion}"
		sh "rsync -avh ${appservers} intershop1@${appservers}:/opt/intershop/install/new_workspace"
		sh "ssh -t intershop1@${appservers} ASSEMBLY=${nexusversion} sh /opt/intershop/install/new_workspace/${appservers}/deploy.sh"
		}
}

def performWebserverDeployment(String webservers) {
    stage("${webservers}") {
        echo "Building the ${webservers}"
		echo "${nexusversion}"
		sh "rsync -avh ${webservers} intershop1@${webservers}:/opt/intershop/install/new_workspace --delete-before"
		sh "ssh -t intershop1@${webservers} ASSEMBLY=${nexusversion} sh /opt/intershop/install/new_workspace/${webservers}/deploy.sh"

	    script {
	        
	        if ( params.InvalidatePagecache == true ){
            sh "ssh -t intershop1@${webservers} sh /opt/intershop/install/new_workspace/${webservers}/invalidate_pagecache.sh -o soft"
	        }else {
	            echo "Pagecache is not Invalidated!"
	        }
	        
	    }
        }
    
}



pipeline {
agent any
options { timestamps () }
    parameters {
		string(name: 'nexusversion',defaultValue: 'NIL', 											 description: 'Nexus Version Number', trim: true)
		string(name: 'sfs', 		defaultValue: 'pls-sfs-p02', 									 description: 'SFS Node')
	    string(name: 'appslist', 	defaultValue: 'pls-aps-p02,pls-aps-p03', 						 description: 'App Nodes')
		string(name: 'weblist',   	defaultValue: 'pls-www-p02,pls-www-p03', 						 description: 'Web Nodes')
		booleanParam                defaultValue: false, description: 'Check to remove pagecache', name: 'InvalidatePagecache'
    }

environment {
		
			def nexusversion = "${params.nexusversion}"
		}

    stages {

		stage('check User') {
        	steps {
            	wrap([$class: 'BuildUser']) {
                	script {
                    	USER_ID = "${BUILD_USER_ID}"
                	}
                }
				script {
 					currentBuild.description = "Nexus Version: ${nexusversion}"
 				}
            }	
        }

		stage('Pauze PRTG sensors') {
        	steps {
				httpRequest('https://prtg.eperium.nl/api/pause.htm?id=8440&pausemsg=deployment&action=0&username=deploymentplus&passhash=1912947534')
            }	
        }
	 
		stage('share') {
	       when {
			   allOf{
                expression { nexusversion != 'NIL' }
				expression { USER_ID ==~ /(admin|duggalk|agarwala|singhp|srajvanshi|ssgeorge|ragarwal|singhv|jmohammad|bisschopj|flinsenbergn)/ }
			   }  
           }
			steps {
				script {
					def sfs = [:]
					for (share in params.sfs.tokenize(',')) {
						performsfsDeployment(share)
							
					}
						
				}
			}
		}
	
		stage('apps') {
	       when {
			   allOf{
                expression { nexusversion != 'NIL' }
				expression { USER_ID ==~ /(admin|duggalk|agarwala|singhp|srajvanshi|ssgeorge|ragarwal|singhv|jmohammad|bisschopj|flinsenbergn)/ }
			   }  
           }
			steps {
				script {
					def appslist = [:]
					for (appservers in params.appslist.tokenize(',')) {
						performAppserverDeployment(appservers)
							
					}
						
				}
			}
		}
	

	  	stage('web') {
	       when {
			   allOf{
                expression { nexusversion != 'NIL' }
				expression { USER_ID ==~ /(admin|duggalk|agarwala|singhp|srajvanshi|ssgeorge|ragarwal|singhv|jmohammad|bisschopj|flinsenbergn)/ }
			   }  
           }
			steps {
				script {
					def weblist = [:]
					for (webservers in params.weblist.tokenize(',')) {
						performWebserverDeployment(webservers)
							
					}	
				}
			}
		}
		stage('Resume PRTG sensors') {
        	steps {
				httpRequest('https://prtg.eperium.nl/api/pause.htm?id=8440&action=1&username=deploymentplus&passhash=1912947534')
				httpRequest('https://prtg.eperium.nl/api/scannow.htm?id=8440&username=deploymentplus&passhash=1912947534')
            }	
        }
	}
}
