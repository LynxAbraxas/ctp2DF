#!/bin/sh

SPRITES=$( ls -1 sprites/???.blend | grep -o '[0-9]\{3\}' )
for RES_FILE in $SPRITES ; do
    echo "Rendering ${RES_FILE}"
    
    docker run --rm -v $(pwd)/sprites/:/media/ ikester/blender /media/${RES_FILE}.blend -o //${RES_FILE}/GG${RES_FILE}A.### -a || exit 1

    for f in sprites/${RES_FILE}/*.tif ; do
	echo -n "$f "
	mogrify -background black -alpha Background -type TrueColorMatte $f || exit 2
	convert  $f -alpha set -fill '#FFFFFFFF' -draw 'color 0,0 reset' -type TrueColorMatte ${f/A/S} || exit 3
    done

    awk -f sprites/bin/spriteFileGen.awk -v nf=$(ls -1 sprites/${RES_FILE}/*A*.tif | wc -l) > GG${RES_FILE}.txt

    touch GG${RES_FILE}.spr # file must exist for docker bind of file
    chmod a+rw GG${RES_FILE}* # user inside docker must have write permission!

    ## append sprite series folder, import TXT and export SPR to DOCKER_PARAMS
    DOCKER_PARAMS="${DOCKER_PARAMS} -v $(pwd)/sprites/${RES_FILE}/:/opt/ctp2/ctp2_program/ctp/${RES_FILE}/ "
    DOCKER_PARAMS="${DOCKER_PARAMS} -v $(pwd)/GG${RES_FILE}.txt:/opt/ctp2/ctp2_data/default/graphics/sprites/GG${RES_FILE}.txt "
    DOCKER_PARAMS="${DOCKER_PARAMS} -v $(pwd)/GG${RES_FILE}.spr:/opt/ctp2/ctp2_data/default/graphics/sprites/GG${RES_FILE}_.spr "

    echo "${RES_FILE} done."
done

## $(pwd) needs to be evaluated in DOCKER_PARAMS
DOCKER_PARAMS=$(eval echo\ $DOCKER_PARAMS)
echo $DOCKER_PARAMS

docker run \
       --env DISPLAY \
       -v ${SHARED_PATH}/.X11-unix/:/tmp/.X11-unix/ \
       -v $(pwd)/.civctp2/save/:/opt/ctp2/ctp2_program/ctp/save/ \
       $DOCKER_PARAMS \
       $IMAGE_TAG:testSprite \
       ./ctp2 $CTP_PARAMS &

pidD=$!
       
java -cp "/opt/sikulixapi.jar:/opt/jython-standalone-2.7.1.jar" org.python.util.jython tests/create-sprite.sikuli/create-sprite.py $SPRITES || exit $?

kill $pidD

mkdir -p newSprites/
mv GG*.spr newSprites/

ls newSprites/

## rename new sprites to the corresponding case used in ctp2 or ctp2CD (expecting ctp2CD to equal ctp2 in case of overlap)
cd newSprites/ &&
    paste -d ' ' \
	  <(ls -1 GG*.spr \
		| sort -f) \
	  <(find ../ctp2/ctp2_data/ ../ctp2CD/ctp2_data/ -type f \
		| grep -i -oFf <(ls -1 GG*.spr) \
		| sort -f) \
	| xargs -n 2  mv -n

ls newSprites/
