# A base for the container. By default fetching from DockerHub (hub.docker.com)
FROM osrf/ros:humble-desktop-full

# Create workspace folders (main_workspace for our work, package_workspace for 3rd party packages) and copy code in there
ENV MAIN_WORKSPACE=/main_workspace
ENV PACKAGE_WORKSPACE=/package_ws
RUN mkdir -p $MAIN_WORKSPACE/src
# COPY src/ $MAIN_WORKSPACE/src/
RUN mkdir -p $PACKAGE_WORKSPACE/src

ARG UNAME=user
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} -o ${UNAME}
RUN useradd -m -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME}
RUN usermod -aG sudo ${UNAME}
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER ${UNAME}

WORKDIR '/home/user' 

RUN sudo apt install curl && \
    curl 'https://raw.githubusercontent.com/Interbotix/interbotix_ros_manipulators/main/interbotix_ros_xsarms/install/amd64/xsarm_amd64_install.sh' > xsarm_amd64_install.sh && \
    chmod +x xsarm_amd64_install.sh && \
    ./xsarm_amd64_install.sh -d humble -p '/home/user' -n

# Install turtlesim for visualization
# RUN apt update && apt install -y ros-humble-turtlesim

# installing the velodyne drivers to the PACKAGE_WORKSPACE
# RUN cd ${PACKAGE_WORKSPACE} && \
#     cd src && \
#     git clone -b ros2 https://github.com/ros-drivers/velodyne.git && \
#     cd .. && \
#     . /opt/ros/${ROS_DISTRO}/setup.sh && \
#     apt-get update -y && \
#     rosdep install --from-paths src --ignore-src -r -y --rosdistro ${ROS_DISTRO}&& \
#     colcon build && \
#     rm -rf ${PACKAGE_WORKSPACE}/src ${PACKAGE_WORKSPACE}/build ${PACKAGE_WORKSPACE}/logs && \
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/*

# Build our ros packages
# RUN  cd ${MAIN_WORKSPACE} && \
#      . /opt/ros/$ROS_DISTRO/setup.sh && \
#      apt-get update -y && \
#      rosdep install --from-paths src --ignore-src -r -y --rosdistro ${ROS_DISTRO} && \
#      colcon build

# Opening new terminals will now have workspace sourced
RUN echo '. /opt/ros/$ROS_DISTRO/setup.sh' >> ~/.bashrc && \
    echo '. /home/user/install/setup.bash' >> ~/.bashrc
    # echo '. $PACKAGE_WORKSPACE/install/setup.bash' >> ~/.bashrc && \
    # echo '. $MAIN_WORKSPACE/install/setup.bash' >> ~/.bashrc

COPY ros_entrypoint.sh /ros_entrypoint.sh
ENTRYPOINT ["/ros_entrypoint.sh"]

CMD ["bash"]