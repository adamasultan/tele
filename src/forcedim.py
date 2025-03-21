# forcedim.py
import ctypes
from ctypes import c_double, c_int, POINTER

# Load DLL (adjust path if needed)
fdlib = ctypes.CDLL('./forcedim_wrapper.dll')

# Define C function interfaces
fdlib.initDevice.restype = c_int
fdlib.closeDevice.restype = None
fdlib.getPose.argtypes = [POINTER(c_double), POINTER(c_double), POINTER(c_double),
                          POINTER(c_double), POINTER(c_double), POINTER(c_double)]
fdlib.getPose.restype = c_int

def init():
    if fdlib.initDevice() < 0:
        raise RuntimeError("Failed to initialize haptic device")

def close():
    fdlib.closeDevice()

def get_pose():
    x = c_double()
    y = c_double()
    z = c_double()
    oa = c_double()
    ob = c_double()
    og = c_double()

    result = fdlib.getPose(ctypes.byref(x), ctypes.byref(y), ctypes.byref(z),
                           ctypes.byref(oa), ctypes.byref(ob), ctypes.byref(og))
    if result != 0:
        raise RuntimeError(f"Failed to get pose, code {result}")

    return [x.value, y.value, z.value,oa.value, ob.value, og.value]
