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
    python3-vcstool \
    python3-rosdep \
    libboost-all-dev \
  && rm -rf /var/lib/apt/lists/*

# Add RealSense udev rules
RUN wget -O /etc/udev/rules.d/99-realsense-libusb.rules https://raw.githubusercontent.com/IntelRealSense/librealsense/master/config/99-realsense-libusb.rules

# Initialize rosdep (safe to re-run)
RUN rosdep init || true

# Fix permissions and update
RUN rosdep fix-permissions && rosdep update

# Create ROS 2 workspace and clone Robotiq gripper packages
RUN mkdir -p /root/ros2_ws/src
WORKDIR /root/ros2_ws/src

RUN git clone -b controller_fix https://github.com/flynnbm/ros2_robotiq_gripper.git

WORKDIR /root/ros2_ws

RUN . /opt/ros/jazzy/setup.sh && \
    vcs import src --skip-existing --input src/ros2_robotiq_gripper/ros2_robotiq_gripper.rolling.repos

RUN . /opt/ros/jazzy/setup.sh && \
    apt-get update && \
    rosdep update && \
    rosdep install --from-paths src --ignore-src --rosdistro jazzy -y && \
    colcon build --symlink-install

# Setup environment sourcing and DDS config
RUN echo "source /opt/ros/jazzy/setup.bash" >> /root/.bashrc && \
    echo "source /root/ros2_ws/install/setup.bash" >> /root/.bashrc

CMD ["bash"]