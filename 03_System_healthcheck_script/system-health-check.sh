#!/bin/bash

LOG_PATH="/home/prasiddha/assignment/project/logs/weekly/health_$(date +%Y_%m_%d).log"

FUNCTIONS=(check_memory check_disk top_processes_by_cpu)

print_header() {
	echo -e "\n----------------------------------------------------------------------" >> $LOG_PATH
	echo "# $1 " >> $LOG_PATH
	echo "----------------------------------------------------------------------" >> $LOG_PATH
	
}

# to check if memory usage, >80% fires warning in log
check_memory() {
	local MEM_USAGE=$(free | awk -F " " 'NR==2 {PER = ($3/$2)*100; printf "%.2f%%", PER; }')
	# cut is used to remove % symbol from MEM_USAGE
	if [ $(cut -d "." -f 1 <<< ${MEM_USAGE}) -gt 80 ]; then
		echo "High_memory_usage_warning Memory_usage_${MEM_USAGE}" >> $LOG_PATH
	else
		echo "Memory_usage OK with ${MEM_USAGE} < 80%" >> $LOG_PATH
	fi
}

# to check disk usage, > 70% use for any mount fires warning in log
check_disk() {
	#flag to track if any mount triggers warning
	local DISK_FLAG=0

	while read -r fs blocks used avail use mount; do
		# cut is used to remvoe % symbol from use
		if [[ $(cut -d "%" -f 1 <<< ${use}) -gt 70 ]]; then
			echo "High_disk_usage_warning ${use}_used_by_mount:${mount}" >> $LOG_PATH
			DISK_FLAG=$(($DISK_FLAG + 1))
		fi
	done < <(df)
	# <(command) => this is called process substitution
	# gives output of command as pseudo-file (like /dev/fd/63)

	# flag==0 means none of the mounts triggered disk warning
	if [ $DISK_FLAG -eq 0 ]; then
		echo "Disk_usage OK with all mounts_usage < 70%" >> $LOG_PATH
	fi
}

# print top 5 processes by CPU
top_processes_by_cpu() {
	{
	  echo "No. of running processes: $(ps aux --no-headers | wc -l)"
	  echo ""
	  echo "Top 5 processes by CPU"
	  ps aux --sort=-%cpu | head -n 6
	} >> $LOG_PATH
}


# Main Report Section
print_header 'SYSTEM INFORMATION' >> $LOG_PATH
echo "Hostname  : $(hostname)" >> $LOG_PATH
echo "Uptime    : $(uptime -p)" >> $LOG_PATH
echo "Date/Time : $(TZ="Asia/Kathmandu" date +"%Y-%m-%d %H-%M-%S_NPT")" >> $LOG_PATH

# call every function
for function in ${FUNCTIONS[@]}; do
	print_header "$function"
	$function
done

cat ${LOG_PATH}
