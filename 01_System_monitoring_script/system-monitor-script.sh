#!/bin/bash
# ============================================
# system_report - Simple System Health Check
# Author: [Prasiddha Bhattarai]
# ============================================

DATE_NOW=$(TZ="Asia/Kathmandu" date +"%Y-%m-%d %H:%M:%S")
DATE_FILE=$(TZ="Asia/Kathmandu" date +"%Y-%m-%d_%H-%M-%S_NT")
REPORT_FILE="/home/prasiddha/logs/system_reports/${DATE_FILE}.txt"
echo "Report_file: ${REPORT_FILE}"

echo "====================================================================" >> ${REPORT_FILE}
echo "system_report - Simple System Health Check" >> ${REPORT_FILE}
echo "Host: $(hostname)" >> ${REPORT_FILE}
echo "DATE: ${DATE_NOW} Nepal Time" >> ${REPORT_FILE}
echo "====================================================================" >> ${REPORT_FILE}

print_header() {
	echo -e "\n" >> ${REPORT_FILE}
	echo "====================================================================" >> ${REPORT_FILE}
	echo "$1" >> ${REPORT_FILE}	
	echo "====================================================================" >> ${REPORT_FILE}
}


# --- Top 2 CPU consuming processes ---
print_header "Top 3 CPU-Consuming Processes"
ps aux --sort=-%cpu | head -4 | awk '{print $2 "\t" $3 "\t" $11}' >> ${REPORT_FILE}


# --- Memory used percentage ---
print_header "Memory usage percentage"
free | awk -F " " 'NR==2 {PER = ($3/$2)*100 } NR==2 {printf "Memory Used: %.2f%%\n", PER }' >> ${REPORT_FILE}


# --- Partition using > 45% ---
print_header "Partition with high(>45%) disk usage"
df -h | awk -F " " 'NR==1 {print $1 "\t" $2 "\t" $3 "\t" $5} $5+0 > 45 {print $1 "\t" $2 "\t" $3 "\t" $5}' >> ${REPORT_FILE}
# "+0"=> converts leading(prefix) numeric part into number. But only prefix part


# --- Top 5 largest file in /var/log/ --
print_header "Top 5 largest file in /var/log/"
find /var/log/ -type f -exec du -ha {} + 2>/dev/null | sort -hr | head -5 >> ${REPORT_FILE}


# --- Starting and killing background process --
print_header "Starting and killing background process"
sleep 999 &
sleep 99 &
#tail -f /var/log/syslog | tail -3 &
echo -e "\nCurrent background processes, jobs:" >> ${REPORT_FILE}
jobs >> ${REPORT_FILE} 
echo -e "\nChecking status and deleting them" >> ${REPORT_FILE}
for pid in $(jobs -p); do
	ps "${pid}" >> ${REPORT_FILE}
	kill -15 "${pid}" >> ${REPORT_FILE}
done
echo -e "\nAfter deletion, jobs:" >> ${REPORT_FILE}
sleep 1
jobs >> ${REPORT_FILE} 


cat ${REPORT_FILE}
