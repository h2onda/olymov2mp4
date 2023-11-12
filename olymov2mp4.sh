#!/bin/bash

FFMPEG=ffmpeg
FFPROBE=ffprobe

ACODEC=aac
VCODEC=copy
FORMAT=ipod

usage()
{
	echo Usage: $(basename $0) [-o OUTPUT] [-f START] [-t END] [ -z ZONEOFFSET] INPUT ...
}

start_time=0
end_time=9999
ZONEOFFSET=0

while getopts 'o:f:t:z:h' args $*
do
    case $args in
		o) OUTPUTDIR=$OPTARG ;;
		f) start_time=$OPTARG ;;
		t) end_time=$OPTARG ;;
		z) ZONEOFFSET=$OPTARG ;;
        h|?) usage && exit 1 ;;
    esac
done
shift $(($OPTIND - 1))

if [ $# == 0 ]; then
	usage
	exit 1
fi

if [ -z "${OUTPUTDIR}" ]; then
	OUTPUTDIR=${PWD}
elif [ -d "${OUTPUTDIR}" ]; then
	OUTPUTDIR=$(dirname ${OUTPUTDIR})/$(basename ${OUTPUTDIR})
else
	echo "output directory ${OUTPUTDIR} is not found!" > /dev/stderr
	exit 1
fi

olymov2mp4()
{
	declare -a info=($(${FFPROBE} -of json -show_format $1 2>/dev/null | jq -r '.format|[(.duration|tonumber),(.tags.creation_time?|sub("\\.[0-9]+Z";"Z")|fromdate)]|@sh'))
	total_time=${info[0]}
	creation_time=${info[1]}

	export end_time total_time
	[ $(jq -nr '(env.end_time|tonumber) > (env.total_time|tonumber)') == 'true' ] && end_time=$total_time

	export creation_time start_time ZONEOFFSET
	creation_time=$(jq -nr '(env.creation_time|tonumber) + (env.start_time|tonumber) + (env.ZONEOFFSET|tonumber)*60*60|todate')

	OUTPUT=${OUTPUTDIR}/$(basename $1 .MOV).mp4

    $FFMPEG -v error -i $1 -ss ${start_time} -to ${end_time} \
		-c:v copy -c:a aac -f mp4 -y \
		-metadata creation_time=${creation_time} ${OUTPUT}
	touch -r $i ${OUTPUT}
	echo "INFO: convert $i to ${OUTPUT}"
	return $?
}

for i in $*
do
	olymov2mp4 $i
	if [ $? != 0 ]; then
		echo "convert $i is failed!" > /dev/stderr
		exit 1
	fi
done

