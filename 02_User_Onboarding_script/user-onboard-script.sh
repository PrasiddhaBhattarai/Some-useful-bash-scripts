#!/bin/bash

# default username is null if no argument passed
USERNAME="${1:-null}"

# worksapce directory info
DIR_PATH="/home/${USERNAME}/workspace"
DIR_PER=750

# log dir path
LOG_PATH="/home/prasiddha/assignment/project/logs/onboard.log"

# TimeStamp
TIMESTAMP="$(TZ="Asia/Kathmandu" date +"%Y-%m-%d %H:%M:%S_Nepal_Time")"



echo -e "\n================================================================"
echo "User Onboarding Script "
echo "Author: Prasiddha Bhattarai"
echo -e "=================================================================="


echo -e "\n------------------------------------------------------------------"
echo "# creating user "
echo "------------------------------------------------------------------"

# Throw error if username not passed as argument
if [ ${USERNAME} = "null" ]; then
	echo -e  "You need to pass username as argument. \ne.g.: ./task4a.sh dev1 \nExiting with code 1"
	exit 1
fi

# Check if username pre-exists, if not create one
if id ${USERNAME} >/dev/null 2>&1; then
	echo -e "User: ${USERNAME} already exists \nExiting with code 1"
	exit 1
  # creating user along with thiers home dir and bash shell
  # it also auto creates group named after USERNAME and adds user to it
elif sudo useradd -m -s /bin/bash ${USERNAME}; then
	echo "User: ${USERNAME} created successfuly along with home directory and bash shell"
else
	echo "failed to create user: ${USERNAME}"
	echo "......aborting the script"
	exit 1
fi


echo -e "\n------------------------------------------------------------------"
echo "# creating primary group "
echo "------------------------------------------------------------------"

#check if primary group exist for that user and also check its members
if echo -n "Group info: " && getent group ${USERNAME}; then
	echo -n "Group Members" && groups ${USERNAME}
  # create group if doen't exist
elif sudo groupadd ${USERNAME} && sudo gpasswd -a ${USERNAME} ${USERNAME}; then
	echo "Group created explicitly"
	echo -n "Group info: " && getent group ${USERNAME}
	echo -n "Group members: " && groups ${USERNAME}
else
	echo "Failed to create primary group for user: ${USERNAME}"
	echo "......aborting the script and performing cleanup"
	sudo userdel -r ${USERNAME}
	exit 1
fi


echo -e "\n------------------------------------------------------------------"
echo "# setting up workspace "
echo "------------------------------------------------------------------"

if mkdir -p ${DIR_PATH} && chmod ${DIR_PER} ${DIR_PATH} && chown ${USERNAME}:${USERNAME} ${DIR_PATH}; then
	echo -e "Create workspace: ${DIR_PATH} \nSet permission to: ${DIR_PER} \nChanged ownership to: ${USERNAME}:${USERNAME}"
else
	echo "filed to set up workspace: ${DIR_PATH}"
fi	


echo -e "\n------------------------------------------------------------------"
echo "# Writing actions to logs "
echo "------------------------------------------------------------------"

if echo "${TIMESTAMP} Executed_by_$(whoami) Onboarded_${USERNAME}" >> ${LOG_PATH}; then
	echo "Successfully written action logs to : ${LOG_PATH}"
	tail -n 1 ${LOG_PATH}
else
	echo "Failed to write action logs to : ${LOG_PATH}"
fi


echo -e "\n------------------------------------------------------------------"
echo "# Script executed successfully "
echo "------------------------------------------------------------------"

echo "================================================================"
