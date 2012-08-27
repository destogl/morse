from morse.builder.morsebuilder import *

fuchs = Robot('fuchs')

gyr = Sensor('gyroscope')
gyr.configure_mw('socket')
fuchs.append(gyr)

imu = Sensor('imu')
imu.name = 'IMU'
imu.configure_mw('socket')
fuchs.append(imu)

prop = Sensor('property')
prop._property_new('NamesOfProperties', 'distance_ref, steering_ref, velocity_ref, steering_velocity_ref, distance, velocity, torque_left, torque_right')
prop.configure_mw('socket')
fuchs.append(prop)

env = Environment('indoors-1/indoor-1')
env.place_camera([5, -5, 6])
env.aim_camera([1.0470, 0, 0.7854])
