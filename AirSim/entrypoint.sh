#!/bin/bash

# Start virtual X server in the background
# - DISPLAY default is :99, set in dockerfile
# - Users can override with `-e DISPLAY=` in `docker run` command to avoid
#   running Xvfb and attach their screen
if [[ -x "$(command -v Xvfb)" && "$DISPLAY" == ":99" ]]; then
	echo "Starting Xvfb"
	Xvfb :99 -screen 0 1600x1200x24+32 &
fi

# # Check if the ROS_DISTRO is passed and use it
# # to source the ROS environment
# if [ -n "${ROS_DISTRO}" ]; then
# 	source "/opt/ros/$ROS_DISTRO/setup.bash"
# fi

# Use the LOCAL_USER_ID if passed in at runtime
if [ -n "${LOCAL_USER_ID}" ]; then
	echo "Starting with UID : $LOCAL_USER_ID"
	# modify existing user's id
	usermod -u $LOCAL_USER_ID user
	# run as user
	exec gosu user "$@"
else
	exec "$@"
fi

if ${REBUILD}; then
	/root/tools/buildRos2Pkg.sh
fi

if ${WSL}; then
	find /root/AirSim/python -type f -name "*.py" -print0 | xargs -0 sed -i "s/airsim.VehicleClient()/airsim.VehicleClient(ip = str(os.environ\['simhost']), port=41451)/g"
	#find /root/AirSim/python -type f -name "*.py" -print0 | xargs -0 sed -i "s/ip = str(os.environ\['simhost']), port=41451//g" for reverse
fi

$build_path/bin/px4 -d "$build_path/etc" -w $build_path -s $build_path/etc/init.d-posix/rcS &
nohup mavlink-routerd -e 172.19.0.7:14550 127.0.0.1:14550 &

sleep 5s
source /opt/ros/galactic/setup.sh
source /root/AirSim/ros2/install/setup.bash
source /root/px4_ros/install/setup.bash
source /root/ros_ws/install/setup.bash

micrortps_agent -t UDP
sleep 3S

ros2 launch airsim_ros_pkgs airsim_node.launch.py host:=172.19.0.5
sleep 3S

ros2 run integration IntegrationTest
sleep infinity