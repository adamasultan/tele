import ctypes
from ctypes import c_double, c_int, POINTER

# Load DLL
fdlib = ctypes.CDLL('./forcedim_wrapper.dll')

# Bindings
fdlib.initDevice.argtypes = [c_int]
fdlib.initDevice.restype = c_int

fdlib.closeDevice.argtypes = [c_int]
fdlib.closeDevice.restype = None

fdlib.getPose.argtypes = [POINTER(c_double), POINTER(c_double), POINTER(c_double),
                          POINTER(c_double), POINTER(c_double), POINTER(c_double), c_int]
fdlib.getPose.restype = c_int

def init(device_id=0):
    fail = fdlib.initDevice(device_id)
    if fail < 0:
        print(f"error number {fail}")
        raise RuntimeError(f"Failed to initialize haptic device {device_id}")

def close(device_id=0):
    fdlib.closeDevice(device_id)

def get_pose(device_id=0):
    x = c_double(); y = c_double(); z = c_double()
    oa = c_double(); ob = c_double(); og = c_double()

    result = fdlib.getPose(
        ctypes.byref(x), ctypes.byref(y), ctypes.byref(z),
        ctypes.byref(oa), ctypes.byref(ob), ctypes.byref(og), device_id
    )
    if result != 0:
        raise RuntimeError(f"Failed to get pose from device {device_id}, code: {result}")
    return [-x.value*1000+190, # poke forward and back
            -y.value*1000, # left and right
            z.value*1000+308, # up and down
            oa.value, # orientation of the part that holds the ob block. left and right orientation
            -ob.value+90, # orientation along the first block joint that holds the end effector up and down orientation
            -og.value] # orientation of the literal tip (part that holds force sensor) circular at end