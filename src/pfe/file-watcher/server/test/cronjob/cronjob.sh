#!/usr/bin/env bash

# Colors for success and error messages
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;36m'
RESET='\033[0m'

# Set up variables
CW_DIR=~/codewind
CW_TEST_DIR=$CW_DIR/src/pfe/file-watcher/server/test
CODEWIND_REPO=git@github.com:eclipse/codewind.git
TEST_BRANCH="master"
CWCTL_PROJ="y"
POST_CLEANUP="n"
CLEAN_RUN="n"

# Make all options mandatory to ensure cronjob admin knows what exectly each cronjob does, it's for debug purpose
function usage {
    me=$(basename $0)
    cat <<EOF
Usage: $me: [-<option letter> <option value> | -h]
Options:
    -o # Deploy PFE and create projects on local disk - 'y' or 'n' - Default: 'y'
    -t # Test type, currently supports 'local' or 'kube' - Mandatory
    -s # Test suite, currently supports 'functional' - Mandatory
    -p # Post cleanup, post test automation cleanup for cronjob, currently supports 'y' or 'n' - Mandatory
    -c # Clean run - currently supports y' or 'n' - Mandatory
    -b # Branch to run the test on - Optional, default: master
    -h # Display the man page
EOF
}

while getopts "t:s:p:c:b:o:h" OPTION; do
    case "$OPTION" in
        t) 
            TEST_TYPE=$OPTARG
            # Check if test type argument is corrent
            if [[ ($TEST_TYPE != "local") && ($TEST_TYPE != "kube") && ($TEST_TYPE != "both") ]]; then
                echo -e "${RED}Test type argument is not correct. ${RESET}\n"
                usage
                exit 1
            fi
            ;;
        s) 
            TEST_SUITE=$OPTARG
            # Check if test suite argument is corrent
            if [[ ($TEST_SUITE != "functional") && ($TEST_SUITE != "unit") ]]; then
                echo -e "${RED}Test suite argument is not correct. ${RESET}\n"
                usage
                exit 1
            fi
            ;;
        p)
            POST_CLEANUP=$OPTARG
            # Check if post cleanup argument is corrent
            if [[ ($POST_CLEANUP != "y") && ($POST_CLEANUP != "n") ]]; then
                echo -e "${RED}Post cleanup argument is not correct. ${RESET}\n"
                usage
                exit 1
            fi
            ;;
        c) 
            CLEAN_RUN=$OPTARG
            # Check if clean run argument is corrent
            if [[ ($CLEAN_RUN != "y") && ($CLEAN_RUN != "n") ]]; then
                echo -e "${RED}Clean run argument is not correct. ${RESET}\n"
                usage
                exit 1
            fi
            ;;
        b) 
            TEST_BRANCH=$OPTARG
            ;;
        o)
            CWCTL_PROJ=$OPTARG
            # Check if clean workspace argument is correct
            if [[ ($CWCTL_PROJ != "y") && ($CWCTL_PROJ != "n") ]]; then
                echo -e "${RED}Create projects with cwctl argument is not correct. ${RESET}\n"
                usage
                exit 1
            fi
            ;;
        *)
            usage
            exit 0
            ;;
    esac
done

# Check if the mandatory arguments have been set up
if [[ (-z $TEST_TYPE) || (-z $TEST_SUITE) || (-z $POST_CLEANUP) || (-z $CLEAN_RUN) ]]; then
    echo -e "${RED}Mandatory arguments are not set up. ${RESET}\n"
    usage
    exit 1
fi

rm -rf $CW_DIR \
&& git clone $CODEWIND_REPO -b "$TEST_BRANCH" \
&& cd $CW_TEST_DIR

./test.sh -t $TEST_TYPE -s $TEST_SUITE -p $POST_CLEANUP -c $CLEAN_RUN -o $CWCTL_PROJ  && rm -rf $CW_DIR

if [[ ($? -ne 0) ]]; then
    echo -e "${RED}Cronjob has failed. ${RESET}\n"
    exit 1
fi

