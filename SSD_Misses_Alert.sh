#!/bin/sh

# SSD misses limit for each category
PATH=$PATH:/opt/scale/bin
ONESEC_LIMIT=40
ONEMIN_LIMIT=30
FIVEMN_LIMIT=20
FIFTMN_LIMIT=10
ALERT_EMAIL_FROM=hc3@papersolve.com
ALERT_EMAIL_TO=mike@papersolve.com
EMAIL_SERVER=10.2.68.3
# ignore these VMs?
#VM_IGNORE_LIST="bsw-archive ps-wazuh"
# if SSD priority is less than this value, ignore it
#	we set it that way so we don't care as much about it
SSD_PRIORITY_THRESH=8


alertMe() {
# mail is not configured so we have to do this the hard way
SUBJ="SSD Misses Alert!"
BODY="The following VM and DISK triggered the SSD Misses alert:"
echo "HELO $HOSTNAME" > /tmp/ssd_misses_email
echo "MAIL FROM:<$ALERT_EMAIL_FROM>" >> /tmp/ssd_misses_email
echo "RCPT TO:<$ALERT_EMAIL_TO>" >> /tmp/ssd_misses_email
echo "DATA" >> /tmp/ssd_misses_email
echo "From: [$USER] <$ALERT_EMAIL_FROM>" >> /tmp/ssd_misses_email
echo "To: <$ALERT_EMAIL_TO>" >> /tmp/ssd_misses_email
echo "Date: `date`" >> /tmp/ssd_misses_email
echo "Subject: $SUBJ" >> /tmp/ssd_misses_email
echo "" >> /tmp/ssd_misses_email
echo $BODY >> /tmp/ssd_misses_email
echo $vmrow >> /tmp/ssd_misses_email
cat /tmp/$vmdisk >> /tmp/ssd_misses_email
echo "" >> /tmp/ssd_misses_email
echo "." >> /tmp/ssd_misses_email
echo "" >> /tmp/ssd_misses_email
echo "QUIT" >> /tmp/ssd_misses_email

# need to send email with delays
cat /tmp/ssd_misses_email | while read line; do
	sleep 0.1
	echo "$line" 
done | nc -C $EMAIL_SERVER 25
}

# get list of VMs and their UUIDs
sc vm show > /tmp/vmrows
readarray vmrows < /tmp/vmrows

for vmrow in "${vmrows[@]}"; do
	# extract what we care about
	vmuuid=`echo $vmrow | awk '{print $1}'`
	vmname=`echo $vmrow | awk '{print $7}'`
	
	# get list of the disks attached to each VM
	sc vm show display detail uuid $vmuuid | grep VIRTIO_DISK > /tmp/$vmuuid
	readarray vmdisks < /tmp/$vmuuid
	for diskrow in "${vmdisks[@]}"; do
		# get misses for each disk
		vmdisk=`echo $diskrow | awk '{print $5}'`
		# if it's a low priority disk we'll ignore it
		ssdpri=`sc vsd show display list uuid $vmdisk | grep $vmdisk | awk '{print $6}'`
		if [ $ssdpri -lt $SSD_PRIORITY_THRESH ]; then 
			echo "Ignoring $vmdisk because it is priority $ssdpri"
			continue
		fi
		sc vsd show display performance uuid $vmdisk > /tmp/$vmdisk
		vmdisk_misses=`grep Misses /tmp/$vmdisk`
		onesec=`echo $vmdisk_misses | awk '{print  $7}'`; onesec=${onesec%.*}
		onemin=`echo $vmdisk_misses | awk '{print  $8}'`; onemin=${onemin%.*}
		fivemn=`echo $vmdisk_misses | awk '{print  $9}'`; fivemn=${fivemn%.*}
		fiftmn=`echo $vmdisk_misses | awk '{print $10}'`; fiftmn=${fiftmn%.*}
		# alert me if misses are "too high"
		#if [ $onesec -gt $ONESEC_LIMIT ]; then alertMe; continue; fi
		#if [ $onemin -gt $ONEMIN_LIMIT ]; then alertMe; continue; fi
		#if [ $fivemn -gt $FIVEMN_LIMIT ]; then alertMe; continue; fi
		if [ $fiftmn -gt $FIFTMN_LIMIT ]; then alertMe; continue; fi	
	done
done
