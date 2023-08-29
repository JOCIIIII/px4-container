#!/bin/bash

# Fog Generator model link 
# https://app.gazebosim.org/OpenRobotics/fuel/models/Pine%20Tree

# model name and model directory in docker contariner
export MODEL_NAME=fog_generator
export MODEL_DIREC=home/user/gazebo

export WORLD_NAME=default

# Gazebo mapsize
export MAPSIZE=50

# position
    x1="$(( $RANDOM % ${MAPSIZE}+ 1 ))"
    y1="$(( $RANDOM % ${MAPSIZE}+ 1 ))"
    z=0

# spwan model
    gz service -s /world/${WORLD_NAME}/create \
        --reqtype gz.msgs.EntityFactory \
        --reptype gz.msgs.Boolean \
        --timeout 3000 \
        --req 'sdf_filename: ''"'${MODEL_DIREC}'/'${MODEL_NAME}'/model.sdf"
        pose: {position: {x: '$x1', y: '$y1', z: '$z'}}
        ''name: "fire" ''allow_renaming: true'

# change size
    gz topic -t /model/fire/link/fog_link/particle_emitter/emitter/cmd \
        -m gz.msgs.ParticleEmitter \
        -p 'size: {x: '50', y: '50', z: '50'}'
