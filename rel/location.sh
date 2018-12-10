#!/bin/bash
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
