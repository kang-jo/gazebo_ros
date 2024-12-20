#!/bin/bash

source ~/.bashrc  # Reload bashrc to apply the ROS environment setup

### Install dependencies for building ROS packages
sudo apt install -y python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool build-essential

### Initialize rosdep
sudo apt install -y python3-rosdep
sudo rosdep init  # Initialize rosdep
rosdep update  # Update rosdep to get the latest dependencies list

### Gazebo Part: Install Catkin and dependencies
# Install ROS dependencies for Catkin, Python, and ROS tools
sudo apt-get install python3-wstool python3-rosinstall-generator python3-catkin-lint python3-pip python3-catkin-tools
pip3 install osrf-pycommon  # Install osrf-pycommon for ROS-related utilities

### Setup Catkin Workspace if u haven't setup it yet
mkdir -p ~/catkin_ws/src
cd ~/catkin_ws
catkin init  # Initialize the catkin workspace

### Install MAVROS and MAVLink dependencies
wstool init ~/catkin_ws/src

# Generate ROS installation files for MAVROS and MAVLink
rosinstall_generator --upstream mavros | tee /tmp/mavros.rosinstall
rosinstall_generator mavlink | tee -a /tmp/mavros.rosinstall

# Merge the generated rosinstall files into the workspace
wstool merge -t src /tmp/mavros.rosinstall
wstool update -t src

# Install system dependencies using rosdep
rosdep install --from-paths src --ignore-src --rosdistro `echo $ROS_DISTRO` -y

# Build the Catkin workspace
catkin build ## or using catkin_make, use according ur preference (must consistent)

### Source the workspace
echo "source ~/catkin_ws/devel/setup.bash" >> ~/.bashrc
. ~/.bashrc  # Reload the bashrc file

### Install Geographiclib (Geolib) for MAVROS
sudo ~/catkin_ws/src/mavros/mavros/scripts/install_geographiclib_datasets.sh

### Clone IQ Sim repository
cd ~/catkin_ws/src
git clone https://github.com/Intelligent-Quads/iq_sim.git

### Add IQ Sim model path to Gazebo model path in bashrc
echo "GAZEBO_MODEL_PATH=${GAZEBO_MODEL_PATH}:$HOME/catkin_ws/src/iq_sim/models" >> ~/.bashrc

### Build IQ Sim
cd ~/catkin_ws
catkin build

### Update global environment
source ~/.bashrc

### Install ArduPilot dependencies
cd ~
sudo apt install git
git clone https://github.com/ArduPilot/ardupilot.git
cd ardupilot

# Install required dependencies for ArduPilot
Tools/environment_install/install-prereqs-ubuntu.sh -y
. ~/.profile  # Reload environment variables

### Checkout to a specific ArduPilot version
git checkout Copter-4.0.4
git config --global url.https://.insteadOf git://
git submodule update --init --recursive  # Initialize git submodules

### Run ArduPilot simulation
cd ~/ardupilot
sim_vehicle.py -w  # Start the simulation with -w flag for additional features

