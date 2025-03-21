# joint_monitor.py
import matlab.engine
import time

# Start MATLAB engine
eng = matlab.engine.start_matlab()
eng.addpath("../matlabsrc", nargout=0)
adsClt = eng.start_ads_client()

# Set up print lock (even if unused here, keeps logic compatible)
print_lock = None

# Define and reuse the same logic as print_joint_list_forever()
def print_joint_list_forever(R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6):
    while True:
        try:
            R1_Joint = eng.meca1_GetJoints(adsClt, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6)
            rounded_list = [round(value, 2) for value in R1_Joint[0]]
            print(f"\rCurrent Joint Positions: {rounded_list}", end="", flush=True)
            time.sleep(0.2)
        except KeyboardInterrupt:
            print("\nStopping joint monitor...")
            break


# Setup variables (reusing same pattern as your original code)
def matlab_global_vars():
    eng.eval("global Move_command; Move_command = adsClt.ReadSymbolInfo('Main.Values');", nargout=0)
    eng.eval("""
        global R1_j1 R1_j2 R1_j3 R1_j4 R1_j5 R1_j6;
        R1_j1 = adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Joint_Set.SubIndex_001');
        R1_j2 = adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Joint_Set.SubIndex_002');
        R1_j3 = adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Joint_Set.SubIndex_003');
        R1_j4 = adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Joint_Set.SubIndex_004');
        R1_j5 = adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Joint_Set.SubIndex_005');
        R1_j6 = adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Joint_Set.SubIndex_006');
    """, nargout=0)

def setup_matlab_vars():
    eng.workspace["adsClt"] = adsClt
    matlab_global_vars()
    R1_j1 = eng.workspace["R1_j1"]
    R1_j2 = eng.workspace["R1_j2"]
    R1_j3 = eng.workspace["R1_j3"]
    R1_j4 = eng.workspace["R1_j4"]
    R1_j5 = eng.workspace["R1_j5"]
    R1_j6 = eng.workspace["R1_j6"]
    return R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6


if __name__ == '__main__':
    try:
        R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6 = setup_matlab_vars()
        print_joint_list_forever(R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6)
    finally:
        print("\nClosing MATLAB engine...")
        eng.quit()
