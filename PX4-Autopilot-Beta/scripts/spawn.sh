#!/bin/bash

# Spawn 100 Tree

# Pine Tree model link 
# https://app.gazebosim.org/OpenRobotics/fuel/models/Pine%20Tree
# There is a error when just start with Pine Tree model downloaded, Because directory is 'Pine Tree'
# If you download this model, you have to run 'cd /home/user/gazebo && sed -i s/Pine Tree/pine_tree/g /model.sdf'


# model name and model directory in docker contariner
export MODEL_NAME=pine_tree
#export MODEL_DIREC=home/user/gazebo
export MODEL_DIREC=home/user/PX4-Autopilot/Tools/simulation/gz/models


export WORLD_NAME=default

# Gazebo mapsize
export MAPSIZE=50

# Spawn Tree
for ((i=1; i<=25; i++))
do
# position
    x1="$(( $RANDOM % ${MAPSIZE}+ 1 ))"
    y1="$(( $RANDOM % ${MAPSIZE}+ 1 ))"

    x2=-"$(( $RANDOM % ${MAPSIZE}+ 1 ))"
    y2="$(( $RANDOM % ${MAPSIZE}+ 1 ))"

    x3="$(( $RANDOM % ${MAPSIZE}+ 1 ))"
    y3=-"$(( $RANDOM % ${MAPSIZE}+ 1 ))"

    x4=-"$(( $RANDOM % ${MAPSIZE}+ 1 ))"
    y4=-"$(( $RANDOM % ${MAPSIZE}+ 1 ))"

    z=0
# spwan model
    gz service -s /world/${WORLD_NAME}/create \
        --reqtype gz.msgs.EntityFactory \
        --reptype gz.msgs.Boolean \
        --timeout 3000 \
        --req 'sdf_filename: ''"'${MODEL_DIREC}'/'${MODEL_NAME}'/model.sdf"
        pose: {position: {x: '$x1', y: '$y1', z: '$z'}}
        ''name: "pine_tree'$i'" ''allow_renaming: true'

    gz service -s /world/${WORLD_NAME}/create \
        --reqtype gz.msgs.EntityFactory \
        --reptype gz.msgs.Boolean \
        --timeout 3000 \
        --req 'sdf_filename: ''"'${MODEL_DIREC}'/'${MODEL_NAME}'/model.sdf"
        pose: {position: {x: '$x2', y: '$y2', z: '$z'}}
        ''name: "pine_tree'$i'" ''allow_renaming: true'

    gz service -s /world/${WORLD_NAME}/create \
        --reqtype gz.msgs.EntityFactory \
        --reptype gz.msgs.Boolean \
        --timeout 3000 \
        --req 'sdf_filename: ''"'${MODEL_DIREC}'/'${MODEL_NAME}'/model.sdf"
        pose: {position: {x: '$x3', y: '$y3', z: '$z'}}
        ''name: "pine_tree'$i'" ''allow_renaming: true'

    gz service -s /world/${WORLD_NAME}/create \
        --reqtype gz.msgs.EntityFactory \
        --reptype gz.msgs.Boolean \
        --timeout 3000 \
        --req 'sdf_filename: ''"'${MODEL_DIREC}'/'${MODEL_NAME}'/model.sdf"
        pose: {position: {x: '$x4', y: '$y4', z: '$z'}}
        ''name: "pine_tree'$i'" ''allow_renaming: true'
done