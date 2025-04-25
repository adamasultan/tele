# Force Dimension–Meca500 Robot Control Bridge

This project provides a Python interface to control Meca500 robots using Force Dimension haptic devices. It bridges hardware, C++ DLLs, Python, and MATLAB/ADS communication for real-time teleoperation and monitoring of robotic arms.

---

## Features

- Real-time mapping of Force Dimension device pose to Meca500 robot position and orientation.
- Safe clamping of robot movements to predefined workspace limits.
- Synchronized control of two robots using two haptic devices.
- MATLAB engine integration for TwinCAT/ADS-based robot communication.
- Threaded architecture for responsive control and safe shutdown.
- Joint monitoring and live feedback.

---

## File Overview

- `forcedim_wrapper.cpp`: C++ DLL wrapper exposing Force Dimension SDK functions for device initialization, closure, and pose retrieval.[2]
- `compilation.txt`: Example command for compiling the C++ wrapper as a DLL.[3]
- `forcedim.py`: Python bindings for the DLL, providing functions to interact with the haptic device.[4]
- `matlabconnection.py`: Utilities to start the MATLAB engine, connect to the ADS client, and set up global robot variables.[7]
- `controller.py`: Main control logic. Initializes devices, homes robots, starts robot control threads, and manages safe shutdown. Maps haptic device pose to robot commands.[5]
- `monitor.py`: Monitors and prints real-time joint positions from the robots using MATLAB ADS communication.[1]

---

## Requirements

- Force Dimension SDK 3.17.6 (and compatible hardware)
- Python 3.x
- MATLAB with Python Engine API
- TwinCAT/ADS system for Meca500 robots
- Required Python libraries: `ctypes`, `matlab.engine`, `threading`, etc.

---

## Setup & Usage

1. **Compile the DLL**

   Use the command in `compilation.txt` to build `forcedim_wrapper.dll` from `forcedim_wrapper.cpp`: 

   `cl forcedim_wrapper.cpp /LD /I"../forcedimension/sdk-3.17.6/include" /link /LIBPATH:"../forcedimension/sdk-3.17.6/lib" dhdms64.lib drdms64.lib`. This may need to be done in the `x64 Native Tools Command Prompt for VS 2022` on your machine.

2. **Configure MATLAB and TwinCAT**
- Ensure MATLAB can start and connect to the TwinCAT ADS client.
- Start the TwinCAT project and Run it in Run Mode
- In `matlabsrc`, run `matlab.engine.shareEngine`

3. **Run the Controller**
- Run `python controller.py`
- The program initializes devices, homes the robots, and starts teleoperation.
- Press `'q'` and Enter to quit safely.

4. **Monitor Joint Values**
Optionally, run `monitor.py` in a separate terminal to print live joint positions.

---

## Notes

- Robot positions are clamped for safety; adjust limits in `controller.py` as needed.
- Device IDs: 0 and 1 correspond to the two Force Dimension devices.
- All critical connections (MATLAB, DLL, hardware) must be established before running.

---

## License

See LICENSE file (if provided) for terms.
