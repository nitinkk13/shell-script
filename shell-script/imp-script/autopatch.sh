#!/bin/bash

###############################################################################
# Confidential - Do not share outside.
# Copyright 2020
###############################################################################

###############################################################################
# autopatch.sh - script to manage automated patching in MCS normally called
#                via cron job /etc/cron.d/infra_patching
#
#0 12 * * 6 root /usr/local/omcs-devops/bin/autopatch.sh kernel 1
#30 12 * * 6 root /usr/local/omcs-devops/bin/autopatch.sh yum 1
#
# Usage: autopatch.sh <mode> <week>
#               mode: one of kernel, user, or yum
#               week: which week of the month to run (1-5)
#
# Contributors: Nitin Kumar, nitinchoudhary13@ymail.com
#
# Possible Improvements:
#       Diskspace check on root.
#       Confirm kernel, initrd, and grub settings after yum.
#       Is BASH the best scripting option?
#       Ensure sane repos defined, OL6 should use UEK4 and OL7 should use UEK5.
###############################################################################

MODE="$1"
WEEK="$2"

LOGFILE="/var/log/autopatch.log"
STATUSFILE="/var/tmp/autopatch.status"
LOCKFILE="/var/run/autopatch.pid"
DATEFMT="%Y-%m-%d_%H:%M:%S"

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

OSRELEASE=$(rpm --query --queryformat '%{VERSION}' oraclelinux-release|cut -c 1)
if [ $OSRELEASE = "6" ]; then
        #Use logger on OL6
        SYSLOG_CMD="logger -p local1.info -t autopatch"
elif [ $OSRELEASE = "7" ]; then
        # Use systemd-cat on OL7
        SYSLOG_CMD="systemd-cat -p info -t autopatch"
else
        # Send to bit-bucket if not OL6 or OL7
        SYSLOG_CMD="cat > /dev/null"
fi

### No changes should be made to the system during the validation of input, day, or stoplight status.

# Begin.
echo "$(date +${DATEFMT}) ===== Starting new autopatch.sh run. =====" >> $LOGFILE
echo "Starting new autopatch.sh run." | $SYSLOG_CMD

# Check if lockfile exists and exit if true.
if [ -r $LOCKFILE ]; then
        echo "$(date +${DATEFMT}) ERROR 1: Lockfile, $LOCKFILE, found. Aborting to avoid dupicate processes." >> $LOGFILE
        echo "ERROR 1: Lockfile, $LOCKFILE, found. Aborting to avoid dupicate processes." | $SYSLOG_CMD
        echo "1" > $STATUSFILE
        exit 1
else
        echo $$ > $LOCKFILE
fi

# Confirm 2 variables passed to the script and exit if not true.
if [ "X${MODE}" = "X" -o "X${WEEK}" = "X" ]; then
        echo "$(date +${DATEFMT}) ERROR 2: Incorrect parameters. Usage: $0 <MODE> <WEEK>" >> $LOGFILE
        echo "ERROR 2: Incorrect parameters. Usage: $0 <MODE> <WEEK>" | $SYSLOG_CMD
        echo "2" > $STATUSFILE
        rm -f $LOCKFILE
        exit 2
fi

# Check if valid mode selected.
case $MODE in
        "kernel")
                PATCH_COMMAND="/usr/bin/ksplice -y kernel upgrade"
                PATCH_STATUS="/var/tmp/autopatch.kernel.status"
                echo "$(date +${DATEFMT}) ksplice kernel patching mode selected." >> $LOGFILE
                ;;
        "user")
                PATCH_COMMAND="/usr/bin/ksplice -y user upgrade"
                PATCH_STATUS="/var/tmp/autopatch.user.status"
                echo "$(date +${DATEFMT}) ksplice user patching mode selected." >> $LOGFILE
                ;;
        "yum")
                PATCH_COMMAND="$(/usr/bin/which yum) update -y"
                PATCH_STATUS="/var/tmp/autopatch.yum.status"
                echo "$(date +${DATEFMT}) yum patching mode selected." >> $LOGFILE
                ;;
        *)
                echo "$(date +${DATEFMT}) ERROR 3: Invalid mode, $MODE, selected. Valid modes are kernel, user, yum" >> $LOGFILE
                echo "ERROR 3: Invalid mode, $MODE, selected. Valid modes are kernel, user, yum" | $SYSLOG_CMD
                echo "3" > $STATUSFILE
                rm -f $LOCKFILE
                exit 3
esac

# Determine upper and lower date ranges for the selected week.
case $WEEK in
        "1")
                LOWER=0
                UPPER=7
                ;;
        "2")
                LOWER=8
                UPPER=14
                ;;
        "3")
                LOWER=15
                UPPER=21
                ;;
        "4")
                LOWER=22
                UPPER=28
                ;;
        "5")
                LOWER=29
                UPPER=31
                ;;
        *)
                echo "$(date +${DATEFMT}) ERROR 4: Invalid week, $WEEK. Expecting number 1-5." >> $LOGFILE
                echo  "ERROR 4: Invalid week, $WEEK. Expecting number 1-5." | $SYSLOG_CMD
                echo "4" > $STATUSFILE
                rm -f $LOCKFILE
                exit 4
esac

# Are we supposed to run today? Check before doing any more work.
DAY=$(date "+%-d")

if [ $DAY -ge $LOWER -a $DAY -le $UPPER ]; then
        echo "$(date +${DATEFMT}) Week match, proceeding with execution." >> $LOGFILE
else
        echo "$(date +${DATEFMT}) ERROR 5: Today ($DAY) is not in the expected range for week $WEEK, ($LOWER - $UPPER), exiting." >> $LOGFILE
        echo "ERROR 5: Today ($DAY) is not in the expected range for week $WEEK, ($LOWER - $UPPER), exiting." | $SYSLOG_CMD
        echo "5" > $STATUSFILE
        rm -f $LOCKFILE
        exit 5
fi

# Determine the regional URL for maintenance control files
MYREGION=$(curl -s http://169.254.169.254/opc/v1/instance/canonicalRegionName)
case $MYREGION in
        "ap-mumbai-1")
                MAINT_URL="http://omcscecruvbrvj-pub.opc.oracleoutsourcing.com/maintain"
                ;;
        "eu-frankfurt-1")
                MAINT_URL="http://omcscbazzjexok-pub.opc.oracleoutsourcing.com/maintain"
                ;;
        "sa-saopaulo-1")
                MAINT_URL="http://omcscdabauklwo-pub.opc.oracleoutsourcing.com/maintain"
                ;;
        "ap-hyderabad-1")
                MAINT_URL="http://omcssdhyd-lb002.opc.oracleoutsourcing.com/maintain"
                ;;
        "us-ashburn-1")
                MAINT_URL="http://omcscabcylivxv-pub.opc.oracleoutsourcing.com/maintain"
                ;;
        "uk-london-1")
                MAINT_URL="http://omcscbbhetasjf-pub.opc.oracleoutsourcing.com/maintain"
                ;;
        "ap-melbourne-1")
                MAINT_URL="http://omcsceeufpdgee-pub.opc.oracleoutsourcing.com/maintain"
                ;;
        "ap-tokyo-1")
                MAINT_URL="http://omcscebmxljomj-pub.opc.oracleoutsourcing.com/maintain"
                ;;
        "us-phoenix-1")
                MAINT_URL="http://omcscaawhsnwdi-pub.opc.oracleoutsourcing.com/maintain"
                ;;
        "ap-sydney-1")
                MAINT_URL="http://omcscedilgmymk-pub.opc.oracleoutsourcing.com/maintain"
                ;;
        "ca-montreal-1")
                MAINT_URL="http://omcs-sd-yul-lb002.opc.oracleoutsourcing.com/maintain"
                ;;
        "ca-toronto-1")
                MAINT_URL="http://omcsccawbmaqvz-pub.opc.oracleoutsourcing.com/maintain"
                ;;
        "eu-zurich-1")
                MAINT_URL="http://omcscbcljtpxeq-pub.opc.oracleoutsourcing.com/maintain"
                ;;
        *)
                # failed to match region
                MAINT_URL="NOT_FOUND"
                echo "$(date +${DATEFMT}) ERROR 6: Unable to determine region." >> $LOGFILE
                echo "ERROR 6: Unable to determine region." | $SYSLOG_CMD
                echo "6" > $STATUSFILE
                rm -f $LOCKFILE
                exit 6
                ;;
esac

# Check stoplight status
STOPLIGHT=$(curl -sf ${MAINT_URL}/stoplight)
if [ $? -ne 0 ]; then
        echo "$(date +${DATEFMT}) ERROR 7: Unable to download stoplight status." >> $LOGFILE
        echo "ERROR 7: Unable to download stoplight status." | $SYSLOG_CMD
        echo "7" > $STATUSFILE
        rm -f $LOCKFILE
        exit 7
fi

if [ "$STOPLIGHT" = "red" ]; then
        echo "$(date +${DATEFMT}) ERROR 8: Stoplight status RED, exiting." >> $LOGFILE
        echo "ERROR 8: Stoplight status RED, exiting." | $SYSLOG_CMD
        echo "8" > $STATUSFILE
        rm -f $LOCKFILE
        exit 8
elif [ "$STOPLIGHT" = "green" ]; then
        echo "$(date +${DATEFMT}) Stoplight status GREEN, proceeding." >> $LOGFILE
else
        echo "$(date +${DATEFMT}) ERROR 9: Unknown stop light status, $STOPLIGHT." >> $LOGFILE
        echo "ERROR 9: Unknown stop light status, $STOPLIGHT." | $SYSLOG_CMD
        echo "9" > $STATUSFILE
        rm -f $LOCKFILE
        exit 9
fi

### We are GO for execution: At this point we are supposed to run based on week
### and stoplight status. Changes may be made to the system.

# Expire old cache
echo "$(date +${DATEFMT}) Expire cached metadata." >> $LOGFILE
yum clean expire-cache >> $LOGFILE 2>&1

# Make sure we are on latest yum and ksplice before main patching.
echo "$(date +${DATEFMT}) Updating yum, yum-plugin-versionlock, and ksplice if update available" >> $LOGFILE
yum update -y yum yum-plugin-versionlock ksplice >> $LOGFILE 2>&1

# Test that versionlock package installed. (above command should install latest so is this test redundant?)
if rpm --quiet --query yum-plugin-versionlock; then
        echo "$(date +${DATEFMT}) Confirmed yum-plugin-versionlock installed." >> $LOGFILE
else
        echo "$(date +${DATEFMT}) yum-plugin-versionlock not installed, attempting to install." >> $LOGFILE
        yum install -y yum-plugin-versionlock >> $LOGFILE 2>&1
        if [ $? -ne 0 ]; then
                echo "$(date +${DATEFMT}) ERROR 10: yum-plugin-versionlock installation failed, unable to proceed." >> $LOGFILE
                echo "ERROR 10: yum-plugin-versionlock installation failed, unable to proceed." | $SYSLOG_CMD
                echo "10" > $STATUSFILE
                rm -f $LOCKFILE
                exit 10
        fi
fi

# Download latest versionfile
echo "$(date +${DATEFMT}) Downloading latest versionlock file." >> $LOGFILE
curl -sf -o /etc/yum/pluginconf.d/versionlock.list ${MAINT_URL}/versionlock/OL${OSRELEASE}/latest

if [ $? -ne 0 ]; then
        echo "$(date +${DATEFMT}) ERROR 11: Unable to download versionlock file." >> $LOGFILE
        echo "ERROR 11: Unable to download versionlock file." | $SYSLOG_CMD
        echo "11" > $STATUSFILE
        rm -f $LOCKFILE
        exit 11
fi

### Main patch execution. Only do retry loop for ksplice commands.
if [ "$MODE" = "kernel" -o "$MODE" = "user" ]; then
        COUNTER=0
        RETURN_VALUE=99
        while [ $COUNTER -lt 3 -a $RETURN_VALUE -ne 0 ]
        do
                echo "$(date +${DATEFMT}) Executing: $PATCH_COMMAND" >> $LOGFILE
                $PATCH_COMMAND >> $LOGFILE 2>&1
                RETURN_VALUE=$?
                echo "$RETURN_VALUE" > $PATCH_STATUS
                if [ $RETURN_VALUE -ne 0 ]
                then
                        echo "$(date +${DATEFMT}) Failed execution, exit status $RETURN_VALUE" >> $LOGFILE
                        COUNTER=$(expr $COUNTER + 1)
                        if [ $COUNTER -lt 3 ]   # Don't sleep after 3rd failure
                        then
                                DELAY=$(echo "$RANDOM / 54 * $COUNTER + 120"|bc)
                                echo "$(date +${DATEFMT}) Sleeping $DELAY seconds and will try again." >> $LOGFILE
                                sleep $DELAY
                        fi
                fi
        done
else
        # Backup some key files
        echo "$(date +${DATEFMT}) Backing up key system config files to /etc/backup" >> $LOGFILE
        test -d /etc/backup || mkdir /etc/backup
        BACKUP_TIMESTAMP=$(date "+%Y%m%d%H%M%S")
        test -d /etc/backup/$BACKUP_TIMESTAMP || mkdir /etc/backup/$BACKUP_TIMESTAMP
        cp -a /etc/passwd /etc/shadow /etc/group /etc/fstab /etc/hosts /etc/resolv.conf /etc/sysctl.conf /etc/crontab /etc/backup/${BACKUP_TIMESTAMP}
        for SUBDIR in cron.d cron.daily cron.hourly cron.monthly cron.weekly sysctl.d security; do
                # Rsync syntax depends on if directory already exists (which it shouldn't in a normal run).
                if test -d /etc/backup/${BACKUP_TIMESTAMP}/${SUBDIR}; then
                        rsync -ax /etc/${SUBDIR}/ /etc/backup/${BACKUP_TIMESTAMP}/${SUBDIR}/
                else
                        rsync -ax /etc/${SUBDIR} /etc/backup/${BACKUP_TIMESTAMP}/
                fi
        done
        test -d /etc/backup/${BACKUP_TIMESTAMP}/sysconfig || mkdir /etc/backup/${BACKUP_TIMESTAMP}/sysconfig
        cp -a /etc/sysconfig/network /etc/backup/${BACKUP_TIMESTAMP}/sysconfig
        test -d /etc/backup/${BACKUP_TIMESTAMP}/sysconfig/network-scripts || mkdir /etc/backup/${BACKUP_TIMESTAMP}/sysconfig/network-scripts
        cp -a /etc/sysconfig/network-scripts/{ifcfg-*,route-*,rule-*} /etc/backup/${BACKUP_TIMESTAMP}/sysconfig/network-scripts 2> /dev/null

        # Main yum patching code
        echo "$(date +${DATEFMT}) Executing: $PATCH_COMMAND" >> $LOGFILE
        $PATCH_COMMAND >> $LOGFILE 2>&1
        RETURN_VALUE=$?
        echo "$RETURN_VALUE" > $PATCH_STATUS
fi

if [ $RETURN_VALUE -eq 0 ]; then
        echo "$(date +${DATEFMT}) $PATCH_COMMAND completed." >> $LOGFILE
        echo "Successful $PATCH_COMMAND execution." | $SYSLOG_CMD
        echo "$(date +${DATEFMT}) Restarting crond." >> $LOGFILE
        service crond restart >> $LOGFILE 2>&1
        echo "$(date +${DATEFMT}) ===== Successful script execution, exit status $RETURN_VALUE =====" >> $LOGFILE
        echo "Successful script execution, exit status $RETURN_VALUE" | $SYSLOG_CMD
        rm -f $LOCKFILE
        echo "0" > $STATUSFILE
        exit 0
else
        # If we reach here, we did not exit after successful patch.
        echo "$(date +${DATEFMT}) ERROR 12: $PATCH_COMMAND failed, aborting." >> $LOGFILE
        echo "ERROR 12: $PATCH_COMMAND failed, aborting." | $SYSLOG_CMD
        echo "$(date +${DATEFMT}) ===== Failed script execution, exit status $RETURN_VALUE =====" >> $LOGFILE
        echo "Failed script execution, exit status $RETURN_VALUE" | $SYSLOG_CMD
        echo "12" > $STATUSFILE
        rm -f $LOCKFILE
        exit 12
fi

