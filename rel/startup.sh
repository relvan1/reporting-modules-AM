#!/bin/bash

working_dir=`pwd`

### Defining Functions ###

fileValidate(){
if [ -f $1 ];then
 
  return 0

else

   echo "File not exists in `pwd` or entered wrong file Name. Please Check";
   return 1;

fi
}

###########################
clusterCreate(){
clusterName=${zoneSelect}-`date +%S%N`

#gcloud container clusters create $clusterName --zone $zoneSelect --num-nodes=1 --machine-type=n1-standard-2 --image-type=ubuntu --node-labels=type=master
gcloud container clusters create $clusterName --zone $zoneSelect --num-nodes=1 --machine-type=n1-standard-1 --image-type=ubuntu
#gcloud container node-pools create slave --cluster $clusterName --zone $zoneSelect --machine-type=n1-standard-8 --image-type=ubuntu --node-labels=type=slave --num-nodes=1

gcloud container clusters get-credentials $clusterName --zone $zoneSelect --project etsyperftesting-208619
}

###########################
deleteCluster(){
delete=true

while $delete;

do

read -p "Do you want to delete the cluster [y/n]: " deleteCluster

        if [[ $deleteCluster == 'y' || $deleteCluster == 'Y' ]]; then

                gcloud container clusters delete $clusterName --zone $zoneSelect --quiet

        elif [[ $deleteCluster == 'n' || $deleteCluster == 'N' ]]; then

                delete=false;
        else
                echo  "Enter a valid response y or n ";
                delete=true;
        fi

delete=false    

done
}

#########################
startTest(){
startTest=true

while $startTest; 

do	

read -p "Your Test is ready.. Press Y to start and N to exit [Y/n]: " startStatus

	if [[ $startStatus == 'y' || $startStatus == 'Y' ]]; then

 		echo "Starting the Test"

            	kubectl exec -it -n $tenant $master_pod -- /jmeter/load_test $jmxFile &

#		sleep 30
#
#                read -p "Do you want to stop the test [Y/n]: " abort
#
#                        if [[ $abort == 'y' || $abort == 'Y' ]]; then
#                                
#				kubectl -n $tenant exec -ti $master_pod -- bash /jmeter/apache-jmeter-4.0/bin/stoptest.sh
#                                
#				sleep 15
#				
#				startTest=false;
#
#                        elif [[ $abort == 'n' || $abort == 'N' ]]; then
#
#                                findDuration
#
#                        else
#
#                                echo  "Wrong Response.Please wait until the test complete."
#
#                                findDuration
#
#                        fi 
		startTest=false;
	elif [[ $startStatus == 'n' || $startStatus == 'N' ]]; then

	       	startTest=false;

        else

		echo  "Enter a valid response y or n: "

		startTest=true;

	fi

done
}

##################################
initializePods(){

tenant=jmeter

kubectl create namespace $tenant

kubectl create clusterrolebinding myname-cluster-admin-binding --clusterrole=cluster-admin --user=natts.softcrylic@gmail.com

kubectl create -n $tenant -f $working_dir/fluentd-configmap.yaml

kubectl create -n $tenant -f $working_dir/jmeter-fluent-configmap.yaml

kubectl create -n $tenant -f $working_dir/fluentd-daemonset.yaml

kubectl create -n $tenant -f $working_dir/jmeter_slaves_deploy.yaml

kubectl create -n $tenant -f $working_dir/jmeter_slaves_svc.yaml

kubectl create -n $tenant -f $working_dir/jmeter_master_configmap.yaml

kubectl create -n $tenant -f $working_dir/jmeter_master_deploy.yaml

sleep 120

master_pod=`kubectl get po -n $tenant | grep jmeter-master | awk '{print $1}'`

kubectl exec -ti -n $tenant $master_pod -- cp  /load_test  /jmeter/load_test

kubectl exec -ti -n $tenant $master_pod -- chmod 755 /jmeter/load_test

}

####################################
findDuration(){

time=true

while $time;

do

cat $jmxFile | grep "ThreadGroup.duration" >/dev/null 2>&1

if [ $? -eq '0' ]; then

	value=`cat $jmxFile | grep "ThreadGroup.duration" | sed 's/[^0-9]*//g'`

	echo "Script will run for $value seconds"

	wait=`expr $value + 10`

	sleep $wait
fi

time=false

done
}

###################################
jmxUploader(){

jmxUpload=true

while $jmxUpload;

do

	read -p "Enter jmx file: " jmxFile

	fileValidate $jmxFile

	if [ $? != 0 ]; then

		jmxUpload=true;

	else

		master_pod=`kubectl get po -n $tenant | grep jmeter-master | awk '{print $1}'`

		kubectl exec -it -n $tenant $master_pod -- bash -c "echo 35.227.203.198 www.etsy.com etsy.com openapi.etsy.com api.etsy.com >> /etc/hosts"

		kubectl cp $jmxFile -n $tenant $master_pod:/$jmxFile

		echo "JMX Copy process completed"

		jmxUpload=false

	fi

done

}

#################################
csvUploader(){

read -p "Do you want to pass csv file [y/n] " csvStatus

csvUpload=true

while $csvUpload;

do

	if [[ $csvStatus == 'y' || $csvStatus == 'Y' ]];then

		csvVerify=true

		while $csvVerify;

		do

		read -p "Enter csv file : " csv

		fileValidate $csv

			if [ $? != 0 ]; then

                		csvVerify=true

        		else

				csvVerify=false

			fi

		done

	elif [[ $csvStatus == 'n' || $csvStatus == 'N' ]];then

		csvUpload=false

	else

   		echo  "Enter a valid response y or n ";

   		csvUpload=true

	fi

echo $csv >> file.csv

read -p "Do you have Extra CSV [Y/n]: " multiCSV

	if [[ $multiCSV == 'y' || $multiCSV == 'Y' ]]; then

   		csvUpload=true;

	elif [[ $multiCSV == 'n' || $multiCSV == 'N' ]]; then

                csvUpload=false;

	else

		echo "Enter a valid response Y or N: "

		csvUpload=true;

	fi

done

}

#########################################
copyCSVfiles(){

slave_pod=`kubectl get po -n $tenant | grep jmeter-slave | awk '{print $1}'`

echo "Please wait for few moments.. we are copying the CSV file"

	for i in $slave_pod

        do

        	kubectl exec -ti -n $tenant $i -- mkdir -p /jmeter/apache-jmeter-4.0/bin/csv/

        	kubectl exec -it -n $tenant $i -- bash -c "echo 35.227.203.198 www.etsy.com etsy.com openapi.etsy.com api.etsy.com >> /etc/hosts"

		copyCSV=`cat file.csv`                                        

			for j in $copyCSV

			do

	        		kubectl cp $j -n $tenant $i:/jmeter/apache-jmeter-4.0/bin/csv/$j

				echo "Copyied!"

			done

	done

}

###Function Definition over###

multiRegion=true

while $multiRegion; 
do
	read -p "Do you want to run Single-Region Test (or) Multi-Region Test [S/M]: " testType

		if [[ $testType == 'S' || $testType == 's' ]]; then

                        setupType="Single-Region"
                
		        multiRegion=false

                else

                        setupType="Multi-Region"

			echo "Multi-Region Yet to configure"

                        exit 0;
                fi
   options=("OREGON" "LOS ANGELES" "IOWA" "SOUTH CAROLINA" "N. VIRGINIA" "MONTRÉAL" "SÃO PAULO" "LONDON" "BELGIUM" "NETHERLANDS" "FRANKFURT" "FINLAND" "MUMBAI" "SINGAPORE" "HONG KONG" "TAIWAN" "TOKYO" "SYDNEY")
   echo "Load Originated From:"
   select Location in "${options[@]}"; do
   	case $Location in
        	'OREGON')
			echo "Oregon Selected"
			regionSelect=us-west1
                	declare -a zones=(us-west1-a us-west1-b us-west1-c)
			zoneSelect=${zones[$(($RANDOM % ${#zones[*]}))]}
                	;;

            	'LOS ANGELES')
			echo "LosAngeles Selected"
 			regionSelect=us-west2
                	declare -a zones=(us-west2-a us-west2-b us-west2-c)
                	zoneSelect=${zones[$(($RANDOM % ${#zones[*]}))]}
                	;;
				
	    	'IOWA')
			echo "IOWA Selected"
                	regionSelect=us-central1
                	declare -a zones=(us-central1-a us-central1-b us-central1-c us-central1-f)
                	zoneSelect=${zones[$(($RANDOM % ${#zones[*]}))]}
                	;;

	    	'SOUTH CAROLINA')
			echo "SouthCarolina Selected"
                	regionSelect=us-east1
                	declare -a zones=(us-east1-b us-east1-c us-east1-d)
                	zoneSelect=${zones[$(($RANDOM % ${#zones[*]}))]}
                	;;

	    	'N. VIRGINIA')
			echo "N.Virginia Selected"
                 	regionSelect=us-east4
                	declare -a zones=(us-east4-a us-east4-b us-east4-c)
            		zoneSelect=${zones[$(($RANDOM % ${#zones[*]}))]}
                        ;;

		'MONTRÉAL')
			echo "Montreal Selected"
                        regionSelect=northamerica-northeast1
                        declare -a zones=(northamerica-northeast1-a northamerica-northeast1-b northamerica-northeast1-c)
                        zoneSelect=${zones[$(($RANDOM % ${#zones[*]}))]}
                        ;;

		'SÃO PAULO')
			echo "SaoPaulo Selected"
                        regionSelect=southamerica-east1
                        declare -a zones=(southamerica-east1-a southamerica-east1-b southamerica-east1-c)
                        zoneSelect=${zones[$(($RANDOM % ${#zones[*]}))]}
                        ;;

		'LONDON')
			echo "London Selected"
                        regionSelect=europe-west2
                        declare -a zones=(europe-west2-a europe-west2-b europe-west2-c)
                        zoneSelect=${zones[$(($RANDOM % ${#zones[*]}))]}
                        ;;

		'BELGIUM')
			echo "Belgium Selected"
                	regionSelect=europe-west1
                        declare -a zones=(europe-west1-b europe-west1-c europe-west1-d)
                        zoneSelect=${zones[$(($RANDOM % ${#zones[*]}))]}
                        ;;

		'NETHERLANDS')
			echo "Netherlands Selected"
                        regionSelect=europe-west4
                        declare -a zones=(europe-west4-a europe-west4-b europe-west4-c)
                        zoneSelect=${zones[$(($RANDOM % ${#zones[*]}))]}
                        ;;

		'FRANKFURT')
			echo "FrankFurt Selected"
                        regionSelect=europe-west3
                        declare -a zones=(europe-west3-a europe-west3-b europe-west3-c)
                        zoneSelect=${zones[$(($RANDOM % ${#zones[*]}))]}
                        ;;

		'FINLAND')
			echo "Finland Selected"
                        regionSelect=europe-north1
                        declare -a zones=(europe-north1-a europe-north1-b europe-north1-c)
                        zoneSelect=${zones[$(($RANDOM % ${#zones[*]}))]}
                        ;;

		'MUMBAI')
			echo "Mumbai Selected"
                        regionSelect=asia-south1
                        declare -a zones=(asia-south1-a asia-south1-b asia-south1-c)
                        zoneSelect=${zones[$(($RANDOM % ${#zones[*]}))]}
                        ;;

		'SINGAPORE')
			echo "Singapore Selected"
                        regionSelect=asia-southeast1
                        declare -a zones=(asia-southeast1-a asia-southeast1-b asia-southeast1-c)
                        zoneSelect=${zones[$(($RANDOM % ${#zones[*]}))]}
                        ;;

		'HONG KONG')
			echo "HongKong Selected"
                        regionSelect=asia-east2
                        declare -a zones=(asia-east2-a asia-east2-b asia-east2-c)
                        zoneSelect=${zones[$(($RANDOM % ${#zones[*]}))]}
                        ;;

		'TAIWAN')
			echo "Taiwan Selected"
                        regionSelect=asia-east1
                        declare -a zones=(asia-east1-a asia-east1-b asia-east1-c)
                        zoneSelect=${zones[$(($RANDOM % ${#zones[*]}))]}
                        ;;

		'TOKYO')
			echo "Tokyo Selected"
                       	regionSelect=asia-northeast1
                        declare -a zones=(asia-northeast1-a asia-northeast1-b asia-northeast1-c)
                        zoneSelect=${zones[$(($RANDOM % ${#zones[*]}))]}
                        ;;

		'SYDNEY')
			echo "Sydney Selected"
                        regionSelect=australia-southeast1
                        declare -a zones=(australia-southeast1-a australia-southeast1-b australia-southeast1-c)
                        zoneSelect=${zones[$(($RANDOM % ${#zones[*]}))]}
                        ;;

		*)

                       	echo -e "You Entered Wrong Input. I am exiting now..Please re-run the script."
                        exit 1;
                        ;;
        esac
	break
   done
done
### calling cluster create function

clusterCreate

### calling initializePods function

initializePods

useExistingCluster=true

while $useExistingCluster;

do

rm -rf file.csv

### Uploading both jmx & csv files and copying files to the pods
	
jmxUploader

csvUploader

copyCSVfiles
	
### calling startTest function

startTest 
		
### Asking user for another test		

read -p "Do you want to run another script  with same $setupType setup [Y/n]?" again

	if [[ $again == 'y' || $again == 'Y' ]]; then

      		useExistingCluster=true

        elif [[ $again == 'n' || $again == 'N' ]]; then

		deleteCluster

	   	useExistingCluster=false

	else

              	read -p "Wrong Response! To start new test press 'Y' & to delete the cluster press 'N': " finalOption

			if [[ $finalOption == 'y' || $finalOption == 'Y' ]]; then 

				useExistingCluster=true

			elif [[ $finalOption == 'n' || $finalOption == 'N' ]]; then

                               	deleteCluster

			else

				echo "Wrong Choice again! Starting to delete the cluster"

				deleteCluster

			fi

	fi	

done
