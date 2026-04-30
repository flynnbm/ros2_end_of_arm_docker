# ROS 2 Jazzy Docker Setup for Raspberry Pi 5

This repository provides a complete setup for using a Raspberry PI 5 as a distributed network pc that can handle perception and grasping from the end of arm of a robotic manipulator. The need is derived from components which typically connect via USB or are otherwise tethered but are not located close to the host machine.

Currently, the repository contains drivers and supports functionality of a connected Intel Realsense D435i depth camera and a Robotiq 2-finger 85 gripper

## Docker Image

TODO:
Pre-built image will be hosted on Docker Hub:

```bash
docker pull flynnbm/ros2-end-of-arm:latest
```

If you get the following error:
```bash
permission denied while trying to connect to the docker API at unix:///var/run/docker.sock
```

Create a new group called docker if one does not already exist:
```bash
sudo groupadd docker
```

And add your user to the group"
```bash
sudo usermod -aG docker $USER
```

Either log out and log back in or use the following command to add changes to your current session
```bash 
newgrp docker
```

Will Contain:

- ROS 2 Jazzy (Ubuntu 24.04)
- RealSense ROS 2 packages (`realsense2_camera`)
- Robotiq ROS 2 packages (`ros2_robotiq_gripper`)
- Tools like `rs-enumerate-devices`, `udev`, `nano`
- Prebuilt `/root/ros2_ws` with RealSense and Robotiq launch files

## Requirements

- Docker & Docker Compose installed on Raspberry Pi 5
- RealSense camera (D435i tested)
- USB 2.0 or 3.0 cable (USB 2.0 strongly preferred if functional, USB 3.0 ports on Raspberry Pi occasionally present issues)
- USB to RS485 connector adapter for Robotiq 2f-85 physical connection
- Another machine with ROS 2 Jazzy installed (for remote operation/visualization)

## Setup Instructions

### 1. Installing Docker & Compose on the Pi

```bash
sudo apt update
sudo apt install docker.io docker-compose
```

### 2. Clone the repository

```bash
git clone https://github.com/flynnbm/<ros2_end_of_arm_docker>.git
cd ros2_end_of_arm_docker
```

### 3. Start the container

```bash
docker-compose up -d
```

Then enter the container:

```bash
docker exec -it ros2_jazzy_dev bash
```

### 4. Launch the RealSense node

Inside the container:

```bash
ros2 launch realsense2_camera rs_pointcloud_launch.py
```

## Notes and Tips

- Plug the RealSense camera **into the Pi before starting the container**  
  If not detected, restart the container **after** plugging the realsense device in to the Raspberry PI
- USB 3.0 works best, but some cables or ports may be unreliable — USB 2.0 fallback can still stream
- Container is configured to source `/root/ros2_ws/install/setup.bash` automatically
- 'ros2-jazzy-<TBD>>` image will be prebuilt, so users don’t need to rebuild anything

### Networking Note

For this setup, do not use `network_mode: host` by default. On the tested desktop configuration, ROS 2 topics from the container were visible to RViz and ROS 2 CLI tools on the host when using Docker’s default networking, but topic discovery did not work as expected when `network_mode: host` was enabled.

If ROS 2 topic discovery fails, first try commenting out `network_mode: host` and restarting the container.

## Reset Docker Environment (optional)

To fully reset Docker:

```bash
docker ps -q | xargs -r docker stop
docker ps -aq | xargs -r docker rm
docker images -q | xargs -r docker rmi
```

To remove just this image:

```bash
docker stop <container_name>
docker rm <container_name>
docker rmi flynnbm/<container_name>
```

## Future Improvements

- Auto-launch realsense node on container start
- Add support for other camera/gripper combinations
- Add `ros2 bag record` or logging setup
