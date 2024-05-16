docker build -t ros_sandbox .

docker compose up

docker exec -it ros_sandbox bash

ros2 launch interbotix_xsarm_perception xsarm_perception.launch.py robot_model:=px100 use_pointcloud_tuner_gui:=true use_armtag_tuner_gui:=true

ros2 service call /px100/torque_enable interbotix_xs_msgs/srv/TorqueEnable "{cmd_type: 'group', name: 'arm', enable: false}"
