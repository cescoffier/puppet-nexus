#!/bin/bash

# Define Nexus Configuration
NEXUS_BASE=
REST_PATH=/service/local
ART_REDIR=/artifact/maven/redirect

usage()
{
cat <<EOF

usage: $0 options

This script will fetch an artifact from a Nexus server using the Nexus REST redirect service.

OPTIONS:
   -h    Show this message
   -v    Verbose
   -a    GAV coordinate groupId:artifactId:version
   -c    Artifact Classifier
   -e    Artifact Packaging
   -o    Output file
   -r	 Repository
   -u    Username
   -p	 Password
   -n    Nexus Base URL

EOF
}

# Read in Complete Set of Coordinates from the Command Line
GROUP_ID=
ARTIFACT_ID=
VERSION=
CLASSIFIER=""
PACKAGING=jar
REPO=
USERNAME=
PASSWORD=
VERBOSE=0

OUTPUT=

while getopts "hva:c:e:o:r:u:p:n:" OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         a)
	     	 OIFS=$IFS
             IFS=":"
		     GAV_COORD=( $OPTARG )
		     GROUP_ID=${GAV_COORD[0]}
             ARTIFACT_ID=${GAV_COORD[1]}
             VERSION=${GAV_COORD[2]}	     
	    	 IFS=$OIFS
             ;;
         c)
             CLASSIFIER=$OPTARG
             ;;
         e)
             PACKAGING=$OPTARG
             ;;
         v)
             VERBOSE=1
             ;;
		 o)
			OUTPUT=$OPTARG
			;;
		 r)
		    REPO=$OPTARG
		    ;;
		 u)
		    USERNAME=$OPTARG
		    ;;
		 p)
		    PASSWORD=$OPTARG
		    ;;
		 n)
			NEXUS_BASE=$OPTARG
			;;
         ?)
             echo "Illegal argument $OPTION=$OPTARG" >&2
             usage
             exit
             ;;
     esac
done

if [[ -z $GROUP_ID ]] || [[ -z $ARTIFACT_ID ]] || [[ -z $VERSION ]]
then
     echo "BAD ARGUMENTS: Either groupId, artifactId, or version was not supplied" >&2
     usage
     exit 1
fi

# Define default values for optional components

# If we don't have set a repository and the version requested is a SNAPSHOT use snapshots, otherwise use releases
if [[ "$REPOSITORY" == "" ]]
then
	if [[ "$VERSION" =~ ".*SNAPSHOT" ]]
	then
		: ${REPO:="snapshots"}
	else
		: ${REPO:="releases"}
	fi
fi
# Construct the base URL
REDIRECT_URL=${NEXUS_BASE}${REST_PATH}${ART_REDIR}

# Generate the list of parameters
PARAM_KEYS=( g a v r p c )
PARAM_VALUES=( $GROUP_ID $ARTIFACT_ID $VERSION $REPO $PACKAGING $CLASSIFIER )
PARAMS=""
for index in ${!PARAM_KEYS[*]} 
do
  if [[ ${PARAM_VALUES[$index]} != "" ]]
  then
    PARAMS="${PARAMS}${PARAM_KEYS[$index]}=${PARAM_VALUES[$index]}&"
  fi
done

REDIRECT_URL="${REDIRECT_URL}?${PARAMS}"

# Authentication
AUTHENTICATION=
if [[ "$USERNAME" != "" ]]  && [[ "$PASSWORD" != "" ]]
then
	AUTHENTICATION="-u $USERNAME:$PASSWORD"
fi

# Output
OUT=
if [[ "$OUTPUT" != "" ]] 
then
	OUT="-o $OUTPUT"
fi

echo "Fetching Artifact from $REDIRECT_URL..." >&2
curl -sS -L ${REDIRECT_URL} ${OUT} ${AUTHENTICATION} -v  --location-trusted --fail
