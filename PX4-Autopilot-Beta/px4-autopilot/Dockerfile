ARG BASEIMAGE
ARG BASETAG

#          __                                     __ 
#    _____/ /_____ _____ ____        ____ _____  / /_
#   / ___/ __/ __ `/ __ `/ _ \______/ __ `/ __ \/ __/
#  (__  ) /_/ /_/ / /_/ /  __/_____/ /_/ / /_/ / /_  
# /____/\__/\__,_/\__, /\___/      \__,_/ .___/\__/  
#                /____/                /_/           

# BASE STAGE FOR CACHINE APT PACKAGE LISTS
FROM ${BASEIMAGE}:${BASETAG} as stage_apt

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV \
    DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

RUN \
    rm -rf /etc/apt/apt.conf.d/docker-clean \
	&& echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache \
	&& sed -i 's/archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list \
    && apt-get update

RUN \
    apt install -y \
        ca-certificates \
        curl \
        software-properties-common \
        wget

RUN \
    add-apt-repository universe -y \
    && add-apt-repository ppa:kisak/kisak-mesa -y

RUN \
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

RUN \
    wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null \
    && apt-get update


#          __                         __          _ __    __         
#    _____/ /_____ _____ ____        / /_  __  __(_) /___/ /__  _____
#   / ___/ __/ __ `/ __ `/ _ \______/ __ \/ / / / / / __  / _ \/ ___/
#  (__  ) /_/ /_/ / /_/ /  __/_____/ /_/ / /_/ / / / /_/ /  __/ /    
# /____/\__/\__,_/\__, /\___/     /_.___/\__,_/_/_/\__,_/\___/_/     
#                /____/                                              

FROM ${BASEIMAGE}:${BASETAG} as stage_builder

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV \
    DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

RUN \
    sed -i 's/archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list

# BUILD DEPENDENCIES OF XRCE-DDS-AGENT
RUN \
    --mount=type=cache,target=/var/cache/apt,from=stage_apt,source=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt,from=stage_apt,source=/var/lib/apt \
    --mount=type=cache,target=/etc/apt/sources.list.d,from=stage_apt,source=/etc/apt/sources.list.d \
    apt-get install -y --no-install-recommends \
        sudo \
        ca-certificates \
        cmake \
        g++ \
        gcc \
        git \
        make

# DEPENDENCIES REQUIRED TO BUILD MAVLINK-ROUTER
RUN \
    --mount=type=cache,target=/var/cache/apt,from=stage_apt,source=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt,from=stage_apt,source=/var/lib/apt \
    --mount=type=cache,target=/etc/apt/sources.list.d,from=stage_apt,source=/etc/apt/sources.list.d \
    apt-get install -y --no-install-recommends \
        g++ \
        gcc \
        git \
        meson \
        ninja-build \
        pkg-config \
        systemd

RUN \
    groupadd user \
    && useradd -ms /bin/zsh user -g user \
    && echo "user ALL=NOPASSWD: ALL" >> /etc/sudoers

# CHANGE USER TO NEWLY GENERATED user AND CHANGE WORKING DIRECTORY TO user's HOME
USER user
WORKDIR /home/user


#          __                          __    __                                  __ 
#    _____/ /_____ _____ ____     ____/ /___/ /____      ____ _____ ____  ____  / /_
#   / ___/ __/ __ `/ __ `/ _ \   / __  / __  / ___/_____/ __ `/ __ `/ _ \/ __ \/ __/
#  (__  ) /_/ /_/ / /_/ /  __/  / /_/ / /_/ (__  )_____/ /_/ / /_/ /  __/ / / / /_  
# /____/\__/\__,_/\__, /\___/   \__,_/\__,_/____/      \__,_/\__, /\___/_/ /_/\__/  
#                /____/                                     /____/                  

FROM stage_builder as stage_dds_agent

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN \
    git clone https://github.com/eProsima/Micro-XRCE-DDS-Agent.git \
    &&  mkdir Micro-XRCE-DDS-Agent/build

RUN \
    cmake -B /home/user/Micro-XRCE-DDS-Agent/build -S /home/user/Micro-XRCE-DDS-Agent \
    && make -C /home/user/Micro-XRCE-DDS-Agent/build

# BUILD RESULTS:
## lib
### /usr/local/lib/libmicroxrcedds_agent.so.2.4.0
### /usr/local/lib/libmicroxrcedds_agent.so.2.4
### /usr/local/lib/libmicroxrcedds_agent.so
## bin
### /usr/local/include/uxr
### usr/local/share/microxrcedds_agent
### /usr/local/bin/MicroXRCEAgent
### /usr/local/include/uxr/agent/config.hpp

### 
### /usr/local/lib/cmake
### /usr/local/lib/cmake/fastcdr

#          __                                                   
#    _____/ /_____ _____ ____        ____ ___  ____ __   _______
#   / ___/ __/ __ `/ __ `/ _ \______/ __ `__ \/ __ `/ | / / ___/
#  (__  ) /_/ /_/ / /_/ /  __/_____/ / / / / / /_/ /| |/ / /    
# /____/\__/\__,_/\__, /\___/     /_/ /_/ /_/\__,_/ |___/_/     
#                /____/                                         

FROM stage_builder as stage_mavlink_router

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV \
    DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# BUILD MAVLKINK-ROUTER. BUID BINARY LOCATES IN mavlink-router/build/src/mavlink-routerd
RUN \
    git clone https://github.com/mavlink-router/mavlink-router -b v3 \
    && git -C mavlink-router submodule update --init --recursive

RUN \
    meson setup mavlink-router/build mavlink-router \
    && ninja -C mavlink-router/build \
    && sudo ninja -C mavlink-router/build install

# usr/bin
# /lib/systemd/system


#          __                         _____             __
#    _____/ /_____ _____ ____        / __(_)___  ____ _/ /
#   / ___/ __/ __ `/ __ `/ _ \______/ /_/ / __ \/ __ `/ / 
#  (__  ) /_/ /_/ / /_/ /  __/_____/ __/ / / / / /_/ / /  
# /____/\__/\__,_/\__, /\___/     /_/ /_/_/ /_/\__,_/_/   
#                /____/                                   

FROM ${BASEIMAGE}:${BASETAG} as stage_final

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV \
    DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

RUN \
    sed -i 's/archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list

# ADD NON-ROOT USER user AND GRANT SUDO PERMISSION
RUN \
    groupadd user \
    && useradd -ms /bin/zsh user -g user

COPY --from=stage_dds_agent \
    /home/user/Micro-XRCE-DDS-Agent /home/user/Micro-XRCE-DDS-Agent

COPY --from=stage_mavlink_router \
    /home/user/mavlink-router/build/src/mavlink-routerd /usr/bin/mavlink-routerd


# DOWNLOAD 
COPY PX4-Autopilot-Beta/px4-autopilot/aptdeps.txt /tmp/aptdeps.txt

# UPGRADE THE BASIC ENVIRONMENT FIRST
RUN \
    --mount=type=cache,target=/var/cache/apt,from=stage_apt,source=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt,from=stage_apt,source=/var/lib/apt \
    --mount=type=cache,target=/etc/apt/sources.list.d,from=stage_apt,source=/etc/apt/sources.list.d \
	apt-get upgrade -y

# INSTALL ca-certifiactes TO AVOID CERTIFICATE ERROR FOR KISAK MESA DRIVERS
RUN \
    --mount=type=cache,target=/var/cache/apt,from=stage_apt,source=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt,from=stage_apt,source=/var/lib/apt \
    --mount=type=cache,target=/etc/apt/sources.list.d,from=stage_apt,source=/etc/apt/sources.list.d \
	apt-get install --no-install-recommends -y \
        ca-certificates

# INSTALL PACKAGES AVAIABLE BY APT REPOSITORY
RUN \
    --mount=type=cache,target=/var/cache/apt,from=stage_apt,source=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt,from=stage_apt,source=/var/lib/apt \
    --mount=type=cache,target=/etc/apt/sources.list.d,from=stage_apt,source=/etc/apt/sources.list.d \
	apt-get install --no-install-recommends -y $(cat /tmp/aptdeps.txt) \
    && rm -rf /tmp/*

# SET LOCALE TO en_UT.UTF-8
RUN \
    --mount=type=cache,target=/var/cache/apt,from=stage_apt,source=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt,from=stage_apt,source=/var/lib/apt \
    --mount=type=cache,target=/etc/apt/sources.list.d,from=stage_apt,source=/etc/apt/sources.list.d \
    apt install -y \
	    locales \
    && locale-gen en_US en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# ADD NON-ROOT USER user AND GRANT SUDO PERMISSION
RUN \
    echo "user ALL=NOPASSWD: ALL" >> /etc/sudoers

# CHANGE USER TO NEWLY GENERATED user AND CHANGE WORKING DIRECTORY TO user's HOME
USER user
WORKDIR /home/user

# FOR EASE OF DEVELOPMENT, INSTALL OH-MY-ZSH AND PLUGINS. SET ALIAS FOR CAT
RUN \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended \
    && sed -i "s/robbyrussell/agnoster/g" ${HOME}/.zshrc \
    && git clone https://github.com/zsh-users/zsh-autosuggestions.git \
        ${HOME}/.oh-my-zsh/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
        ${HOME}/.oh-my-zsh/plugins/zsh-syntax-highlighting \
    && sed -i "s/(git)/(git zsh-autosuggestions zsh-syntax-highlighting)/g" ${HOME}/.zshrc \
    && echo "alias cat='batcat --paging=never'" >> ${HOME}/.zshrc \
        ${HOME}/.o/home/user/PX4-Autopilot/ROMFS/px4fmu_common/init.d-posix

RUN \
    git clone https://github.com/PX4/PX4-Autopilot.git -b v1.14.0-rc1-dev \
    && git -C PX4-Autopilot submodule update --init --recursive

RUN \
    PX4-Autopilot/Tools/setup/ubuntu.sh --no-nuttx --no-sim-tools \
    && sudo apt-get autoremove -y \
    && sudo apt-get clean autoclean \
    && sudo rm -rf /var/cache/apt/archives /var/lib/apt/lists/*

RUN \
    sed -i s/"udp -h 127.0.0.1"/"udp -h \${UXRCE_DDS_AG_IP_NOINT}"/g PX4-Autopilot/ROMFS/px4fmu_common/init.d-posix/rcS \
    && make -C /home/user/PX4-Autopilot px4_sitl

RUN \
    echo "source /opt/ros/humble/setup.zsh" >> ${HOME}/.zshrc

RUN \
    mkdir -p /home/user/px4_ros_uxrce_dds_ws/src \
    && git clone https://github.com/eProsima/Micro-XRCE-DDS-Agent.git \
        /home/user/px4_ros_uxrce_dds_ws/src/Micro-XRCE-DDS-Agent

RUN \
    sudo make -C /home/user/Micro-XRCE-DDS-Agent/build install \
    && sudo ldconfig /usr/local/lib/ \
    && sudo rm -rf Micro-XRCE-DDS-Agent

COPY PX4-Autopilot-Beta/scripts /home/user/scripts

# git clone https://github.com/PX4/px4_ros_com.git ~/px4_ros/src/px4_ros_com
# git -C ~/px4_ros/src/px4_ros_com reset --hard 0bcf68bcb635199adcd134e8932932054e863c0d
# git clone https://github.com/PX4/px4_msgs.git ~/px4_ros/src/px4_msgs
# git -C ~/px4_ros/src/px4_msgs reset --hard ffc3a4cd578776213a444abe17d7eabf9621b266
# rm -rf ~/px4_ros/src/px4_msgs/msg/*.msg ~/px4_ros/src/px4_ros_com/src/examples ~/px4_ros/src/px4_ros_com/launch
# python3 /home/user/PX4-Autopilot/Tools/msg/px_generate_uorb_topic_files.py \
#     -i ~/PX4-Autopilot/msg/tools/urtps_bridge_topics.yaml \
#     -o ~/px4_ros/src/px4_ros_com/templates/urtps_bridge_topics.yaml


COPY PX4-Autopilot-Beta/px4-autopilot/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN \
    sudo ln -s /usr/local/bin/entrypoint.sh /home/user/scripts/entrypoint.sh

CMD [ "/usr/local/bin/entrypoint.sh" ]

# ------ RUN COMMAND (DEFAULT) -----
# docker run -it --rm \
#    -e DISPLAY=$DISPLAY \
#    -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY \
#    -e QT_NO_MITSHM=1 \
#    -e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
#    -e NVIDIA_DRIVER_CAPABILITIES=all \
#    -v /run/user/1000:/run/user/1000 \
#    -v /tmp/.X11-unix:/tmp/.X11-unix \
#    -v /usr/share/vulkan/icd.d/nvidia_icd.json:/etc/vulkan/icd.d/nvidia_icd.json \
#    -v /usr/share/vulkan/implicit_layer.d/nvidia_layers.json:/etc/vulkan/implicit_layer.d/nvidia_layers.json \
#    -v /usr/share/glvnd/egl_vendor.d/10_nvidia.json:/usr/share/glvnd/egl_vendor.d/10_nvidia.json \
#    --device=/dev/dri:/dev/dri \
#    --net host \
#    --ipc host \
#    --gpus all \
#    --user user \
#    --privileged \
#    --name sitl-px4 \
#    kestr3l/px4:1.14.0-rc-0.0.1-dev zsh

# ------- RUN COMMAND (WSL2) -------
# docker run -it --rm \
#    -e DISPLAY=$DISPLAY \
#    -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY \
#    -e QT_NO_MITSHM=1 \
#    -e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
#    -e NVIDIA_DRIVER_CAPABILITIES=all \
#    -e PULSE_SERVER=/mnt/wslg/PulseServer \
#    -e LD_LIBRARY_PATH=/usr/lib/wsl/lib \
#    -v /run/user/1000:/run/user/1000 \
#    -v /tmp/.X11-unix:/tmp/.X11-unix \
#    -v /usr/share/vulkan/icd.d/nvidia_icd.json:/etc/vulkan/icd.d/nvidia_icd.json \
#    -v /usr/share/vulkan/implicit_layer.d/nvidia_layers.json:/etc/vulkan/implicit_layer.d/nvidia_layers.json \
#    -v /usr/share/glvnd/egl_vendor.d/10_nvidia.json:/usr/share/glvnd/egl_vendor.d/10_nvidia.json \
#    -v /mnt/wslg:/mnt/wslg \
#    -v /usr/lib/wsl:/usr/lib/wsl \
#    --device=/dev/dxg \
#    --device=/dev/dri/card0 \
#    --net host \
#    --ipc host \
#    --gpus all \
#    --user user \
#    --privileged \
#    --name sitl-px4 \
#    kestr3l/px4:1.14.0-beta2-0.0.1-dev zsh

# ------- BUILD COMMAND (CUDA) -------
# DOCKER_BUILDKIT=1 docker build --no-cache \
# --build-arg BASEIMAGE=nvidia/cuda \
# --build-arg BASETAG=11.7.1-cudnn8-devel-ubuntu20.04 \
# -t kestr3l/px4:1.14.0-beta2-0.0.1-cuda-dev \
# -f ./PX4-Autopilot-Beta/px4-autopilot/Dockerfile .

# ------- BUILD COMMAND (PLAIN) ------
# DOCKER_BUILDKIT=1 docker build --no-cache \
# --build-arg BASEIMAGE=ubuntu \
# --build-arg BASETAG=22.04 \
# -t kestr3l/px4:1.14.0-beta2-0.0.1-dev \
# -f ./PX4-Autopilot-Beta/px4-autopilot/Dockerfile .