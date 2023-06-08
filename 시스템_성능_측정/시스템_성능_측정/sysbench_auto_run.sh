#!/bin/bash
###################################
#
#  Title : Sysbench performance tool auto run script
#  Author by Alex Lee
#  Date : 02-10-2014
#
###################################


set -u
set -x

#- default
SYSBENCH_HOME="/usr/local/sysbench-0.4.12/bin"
SYSBENCH_BIN="${SYSBENCH_HOME}/sysbench"
OUTPUT_RAW_DATA="/opt/output_raw_data"
OUTPUT_TEMP_FILES="/home/test"
TOTAL_CN=(1 2 3 4)

#- CPU evaluation
CPU_ID=`cat /proc/cpuinfo | grep 'model name' | head -n 1 | awk '{print $5 "_" $6 "_" $7}'`
CPU_MP="100000"
CPU_MR="10000"
CPU_NT=(1 4 8 16)

#- Memory evaluation
MEM_ID=`dmidecode --type 17 | grep -i speed | head -n 1 | awk '{print $2 $3}'`
MEM_MS="100GB"
MEM_MB=(1KB 4KB 16KB)
MEM_MO=(read write)
MEM_NT=(1 4 8 16)

#- Disk(file I/O) evaluation
DISK_TARGET="/dev/sda"
DISK_ID=`sdparm --vendor sea $DISK_TARGET | awk '{print $2 "_" $3 "_" $4}'` 
FILE_FS="5GB"
FILE_FN="10"
FILE_FB=(4KB 512KB)
FILE_MO=(seqrd seqwr rndrd rndwr rndrw)
FILE_NT=(1 4 8 16)

#- CPU runngin fuction
cpu_run() {
	if [ ! -f ${OUTPUT_RAW_DATA}/${CPU_ID}-${CPU_MP} ]; then
		mkdir -p ${OUTPUT_RAW_DATA}/${CPU_ID}-${CPU_MP}
	fi
	
	# running by thread
	for CPU_thr in ${CPU_NT[@]}; do	
		exec >${OUTPUT_RAW_DATA}/${CPU_ID}-${CPU_MP}/${CPU_ID}-${CPU_MP}-${CPU_thr} 2>&1
		echo "`date` BEGIN TESTING ${CPU_ID}-${CPU_MP}-${CPU_thr}"
		
		for i in ${TOTAL_CN[@]}; do
			echo "`date` start iteration $i"
			${SYSBENCH_BIN} --test=cpu --cpu-max-prime=${CPU_MP} --max-requests=${CPU_MR} \
			--num-threads=$CPU_thr run
		done
		
		echo "`date` DONE TESTING ${CPU_ID}-${CPU_MP}-${CPU_thr}"
		sleep 5
	done

	#for CPU_thr in {CPU_NT[@]}; do
	#	wait
	#done
}

#- Memory running function
mem_run() {
	if [ ! -f ${OUTPUT_RAW_DATA}/MEMORY-${MEM_ID}-${MEM_MS} ]; then
		mkdir -p ${OUTPUT_RAW_DATA}/MEMORY-${MEM_ID}-${MEM_MS}
	fi
	
	#- operation mode by read or write
	for MEM_oper in ${MEM_MO[@]}; do
		#- block
		for MEM_block in ${MEM_MB[@]}; do
			#- thread
			for MEM_thr in ${MEM_NT[@]}; do
				exec >${OUTPUT_RAW_DATA}/MEMORY-${MEM_ID}-${MEM_MS}/MEMORY-${MEM_ID}-${MEM_MS}-${MEM_oper}-${MEM_block}-${MEM_thr} 2>&1
				echo "`date` BEGIN TESTING MEMORY-${MEM_ID}-${MEM_MS}-${MEM_oper}-${MEM_block}-${MEM_thr}"

				for i in ${TOTAL_CN[@]}; do
					echo "`date` start iteration $i"
					${SYSBENCH_BIN} --test=memory --memory-total-size=${MEM_MS} --memory-block-size=${MEM_block} \
					--memory-oper=${MEM_oper} --num-threads=${MEM_thr} --memory-scope=global run    					
				done

				echo "`date` DONE TESTING MEMORY-${MEM_ID}-${MEM_MS}-${MEM_oper}-${MEM_block}-${MEM_thr}"
			done
		done
	done
	sleep 5
}

#- Disk (file I/O) running function
disk_run() {
	if [ ! -f ${OUTPUT_RAW_DATA}/${DISK_ID}-${FILE_FS} ]; then
		mkdir -p ${OUTPUT_RAW_DATA}/${DISK_ID}-${FILE_FS}
	fi

	if [ "$@" == "cleanup" ]; then
		cd ${OUTPUT_TEMP_FILES}
		${SYSBENCH_BIN} --test=fileio --file-total-size=${FILE_FS} --file-num=${FILE_FN} "$@"
		sleep 10
	elif [ "$@" == "prepare" ]; then
		cd ${OUTPUT_TEMP_FILES}
		${SYSBENCH_BIN} --test=fileio --file-total-size=${FILE_FS} --file-num=${FILE_FN} "$@"
		sleep 60
	elif [ "$@" == "run" ]; then
		cd ${OUTPUT_TEMP_FILES}

		#- operation mode by seqrd swqwr rndrd rndwr rndrw
		for FILE_oper in ${FILE_MO[@]}; do
			#- blcok
			for FILE_block in ${FILE_FB[@]}; do
				#- thread
				for FILE_thr in ${FILE_NT[@]}; do
					exec >${OUTPUT_RAW_DATA}/${DISK_ID}-${FILE_FS}/${DISK_ID}-${FILE_FS}-${FILE_oper}-${FILE_block}-${FILE_thr} 2>&1
					echo "`date` BEGIN TESTING ${DISK_ID}-${FILE_FS}-${FILE_oper}-${FILE_block}-${FILE_thr}"

					for i in ${TOTAL_CN[@]}; do
						echo "`date` start interation $i"
						${SYSBENCH_BIN} --test=fileio --file-total-size=${FILE_FS} --file-num=${FILE_FN} \
						--file-test-mode=${FILE_oper} --file-block-size=${FILE_block} --num-threads=${FILE_thr} \
						--init-rng=on --file-extra-flags=direct --file-fsync-freq=0 --max-time=300 \
						--max-requests=10000000 "$@"
						sleep 10
					done

					echo "`date` DONE TESTING ${DISK_ID}-${FILE_FS}-${FILE_oper}-${FILE_block}-${FILE_thr}"
				done
			done
		done
	fi
#        $SYSBENCH/sysbench --test=fileio --file-total-size=$size --file-test-mode=$mode \
#          --max-time=60 --max-requests=100000000 --num-threads=$threads \
#          --init-rng=on --file-num=32 --file-extra-flags=direct \
#          --file-fsync-freq=0 --file-block-size=$blksize run 

#        $SYSBENCH/sysbench --test=fileio --file-total-size=$size --file-test-mode=$mode \
#          --num-threads=$threads --file-num=10 \
#          --max-time=60 --init-rng=on --max-requests=1000000 \
#          --file-block-size=$blksize run
#    sleep 10
}

usage() {
	echo "Usage : $0 modename"
	exit 1
}

main() {
	if [ "$@" == "cpu" ]; then
		cpu_run
	elif [ "$@" == "mem" ]; then
		mem_run
	elif [ "$@" == "disk" ]; then
		disk_run cleanup
		disk_run prepare
		disk_run run
	else
		echo " : $@ modename"
		echo "ex) $@ cpu or mem or disk"
	fi
}


if [ $# -eq 0 ]
then 
	usage
else
	main $1
fi

