# forcedim.py
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
    if fdlib.initDevice(device_id) < 0:
        raise RuntimeError(f"Failed to initialize haptic device {device_id}")

def close(device_id=0):
    fdlib.closeDevice(device_id)

def get_pose(device_id=0):
    x = c_double(); y = c_double(); z = c_double()
    oa = c_double(); ob = c_double(); og = c_double()

    result = fdlib.getPose(
        ctypes.byref(x), ctypes.byref(y), ctypes.byref(z),
        ctypes.byref(oa), ctypes.byref(ob), ctypes.byref(og),
        device_id
    )
    if result != 0:
        raise RuntimeError(f"Failed to get pose from device {device_id}, code: {result}")
    
    return [x.value, y.value, z.value, oa.value, ob.value, og.value]