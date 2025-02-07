FROM osrf/ros:noetic-desktop-full
LABEL maintainer="Ignacio Vizzo <ivizzo@uni-bonn.de>"

# Install utilities
RUN apt-get update && apt-get install --no-install-recommends -y \
    git \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install Python3 utils
RUN python3 -m pip install --no-cache  catkin-tools

# Install extra ROS dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
    ros-${ROS_DISTRO}-tf2-sensor-msgs \
    && rm -rf /var/lib/apt/lists/*

# Install OpenVDB dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
    libblosc-dev \
    libboost-iostreams-dev \
    libboost-system-dev \
    libboost-system-dev \
    libeigen3-dev \
    && rm -rf /var/lib/apt/lists/*

# Install OpenVDB from source
RUN git clone --depth 1 https://github.com/nachovizzo/openvdb.git -b nacho/vdbfusion \
    && cd openvdb \
    && mkdir build && cd build \
    && cmake  -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DUSE_ZLIB=OFF .. \
    && make -j$(nproc) all install \
    && cd / \
    && rm -rf /openvdb

# Install VDBFusion from source
RUN git clone --depth 1 https://github.com/PRBonn/vdbfusion.git \
    && cd vdbfusion \
    && mkdir build && cd build \
    && cmake .. \
    && make -j$(nproc) all install \
    && cd / \
    && rm -rf /vdbfusion

# Add user to share files and folder without root permissions
ENV GROUP_ID=1000
ENV USER_ID=1000
RUN addgroup --gid $GROUP_ID user && adduser --disabled-password --gecos '' --uid $USER_ID --gid $GROUP_ID user
USER user

# Build ROS workspace, bash needs the "-l" to load the /etc/profile
WORKDIR /home/user/ros_ws

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash", "--login"]
