# Use ROS 2 Jazzy base image
FROM ros:jazzy-ros-base

ENV DEBIAN_FRONTEND=noninteractive

# Install tools and ROS packages
RUN apt update && apt install -y \
    wget \
    nano \
    udev \
    usbutils \
    python3-pip \
    python3-colcon-common-extensions \
    build-essential \
    curl \
    git \
    iputils-ping \
    net-tools \
    ros-jazzy-realsense2-camera \
    ros-jazzy-librealsense2 \
    ros-jazzy-rviz2 \
  && rm -rf /var/lib/apt/lists/*

# Add RealSense udev rules
RUN wget -O /etc/udev/rules.d/99-realsense-libusb.rules https://raw.githubusercontent.com/IntelRealSense/librealsense/master/config/99-realsense-libusb.rules

# Create ROS 2 workspace
RUN mkdir -p /root/ros2_ws/src
WORKDIR /root/ros2_ws

# Build workspace (empty or pre-cloned)
RUN . /opt/ros/jazzy/setup.sh && colcon build --symlink-install


# Setup environment sourcing and DDS config
RUN echo "source /opt/ros/jazzy/setup.bash" >> /root/.bashrc && \
    echo "source /root/ros2_ws/install/setup.bash" >> /root/.bashrc && \

CMD ["bash"]