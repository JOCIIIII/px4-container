import airsim
import os

c = airsim.VehicleClient(ip = str(os.environ['simhost']), port=41451)
center = airsim.Vector3r(0, 0, 0)
c.simCreateVoxelGrid(center, 25, 25, 20, 0.1,"C:/Users/...x")
# THIS DIRECTORY MUST BE A DIRECTORY OF AIRSIM UNREAL HOST