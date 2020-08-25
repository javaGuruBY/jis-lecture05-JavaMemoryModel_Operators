#!/usr/bin/env bash

## declare jvm arguments variable
declare -a xm_=("2048m")
declare -a newRatio=("-XX:NewRatio=1" "-XX:NewRatio=2" "-XX:NewRatio=3" "-XX:NewRatio=4" "-XX:NewRatio=5")
declare -a survivorRatio=("-XX:SurvivorRatio=1" "-XX:SurvivorRatio=2" "-XX:SurvivorRatio=3" "-XX:SurvivorRatio=4" "-XX:SurvivorRatio=5")
declare -a gcType=("-XX:+UseParallelOldGC" "-XX:+UseG1GC" "-XX:+UseParallelGC" "-XX:+UseSerialGC" "-XX:+UseConcMarkSweepGC")


logFoldersList="../reports/logFoldersList.log"

sudo update-alternatives --config java
read -r -p "print selected jvm  " jvm

#kill if exists
jstatPidString=$(jps | grep Jstat)
jstatPid="${jstatPidString//[\ Jstat]/}"
applicationPidString=$(jps | grep jvm-study-SNAPSHOT.jar)
applicationPid="${applicationPidString//[\ jvm\-studySNAPSHOT.jar]/}"
kill -9 ${jstatPid};
kill -9 ${applicationPid};

runTests() {
	heapArgs="$1 $2 $3 $4 $5 $6"
	ab_n=500
	ab_c=1
#	echo "heap args are $heapArgs"
	gcLogArgs="-XX:+PrintCommandLineFlags -verbose:gc"
	args="$heapArgs $gcLogArgs"

	application="../jvm-study/target/jvm-study-SNAPSHOT.jar"

	#take java version from system and JVM arguments add it to reportDirectoryName
#	version=$(java -version 2>&1 >/dev/null | grep 'java version' | awk '{print $3}')
#	jvm="${version//[-_:X+\"= ]/}"
	directory="${ab_n}_${ab_c}_${jvm}${heapArgs//[-._:X+\"= ]/}"
	destination="../reports/$directory"
	abReport="$destination/abReport.log"
	mkdir ${destination}

	java ${args} -jar ${application} > ${destination}/verbose-gc.log &

	echo "wait for server 10 sec"
	sleep 10s
	applicationPidString=$(jps | grep jvm-study-SNAPSHOT.jar)
	applicationPid="${applicationPidString//[\ jvm\-studySNAPSHOT.jar]/}"
	echo "application start with id $applicationPid"

    jstat -gccapacity -t ${applicationPid} 100 > ${destination}/jstat.log &
    jstatPidString=$(jps | grep Jstat)
    jstatPid="${jstatPidString//[\ Jstat]/}"
    echo "jstat start with id $jstatPid"

	echo "run Apache Bench"
	ab -n ${ab_n} -c ${ab_c} -g ${destination}/abLog.log http://127.0.0.1:8082/ > ${abReport}
	echo ""
	echo "[reports has ben generated at $destination]"
	ls -ahl ${destination}
	echo ""
    kill -9 ${jstatPid};
    kill -9 ${applicationPid};

	string=$(grep -P "Total transferred:" ${abReport})
	totalBytes="${string//[\"Total transferred\: bytes]/}"

	string=$(grep -P "Time taken for tests:" ${abReport})
	timeTaken="${string//[\"Time taken for tests\: seconds]/}"

	string=$(grep -P "Total: " ${abReport})
	minConnectionTime="${string:5:12}"

	string=$(grep -P "50%" ${abReport})
	medianLatency="${string:5:100}"

	string=$(grep -P "95%" ${abReport})
	latencyIn95="${string:5:100}"

    comparisonReport="../reports/${ab_n}_${ab_c}_comparison.log"
	echo "$jvm $heapArgs ${totalBytes//[ ]/} ${timeTaken//[ ]/} ${minConnectionTime//[\: ]/} ${medianLatency//[ ]/} ${latencyIn95//[ ]/}" >> ${comparisonReport}
	echo "$directory $jvm $heapArgs " >> ${logFoldersList}

}

for xm in "${xm_[@]}"
do
   for nR in "${newRatio[@]}"
   do
      for sR in "${survivorRatio[@]}"
      do
        for gc in "${gcType[@]}"
        do
            xms="-Xms$xm"
            xmx="-Xmx$xm"
            runTests "${xmx} ${xms} ${nR} ${sR} ${gc}"
        done
      done
   done
done
