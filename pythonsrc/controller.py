import matlab.engine
import threading
import time
import sys

# Start MATLAB engine
eng = matlab.engine.start_matlab()
eng.addpath("../matlabsrc", nargout=0)
adsClt = eng.start_ads_client()
print_lock = threading.Lock()


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
    Move_command = eng.workspace["Move_command"]
    R1_j1 = eng.workspace["R1_j1"]
    R1_j2 = eng.workspace["R1_j2"]
    R1_j3 = eng.workspace["R1_j3"]
    R1_j4 = eng.workspace["R1_j4"]
    R1_j5 = eng.workspace["R1_j5"]
    R1_j6 = eng.workspace["R1_j6"]
    return Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6

def cli_movement(Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6):
    while True:
        try:
            with print_lock:
                input_string = input("\nEnter joint positions (or 'exit'): ").strip()
            float_array = []
            for val in input_string.split():
                float_array.append(float(val))
            Jmovement = matlab.double([float_array])
            eng.meca1_MoveJoint(adsClt, Move_command, Jmovement, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6, nargout=0)
        except Exception as e:
            print(f"Input error: {e}")

def reset_joints(Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6):
    R1_Joint = eng.meca1_GetJoints(adsClt, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6)
    negative_joint_pose = [-R1_Joint[0][i] for i in range(len(R1_Joint[0]))]
    Jmovement = matlab.double([negative_joint_pose])
    eng.meca1_MoveJoint(adsClt, Move_command, Jmovement, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6, nargout=0)


def home_and_setup(Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6):
    eng.meca1_ETC_Setup(adsClt, nargout=0)
    reset_joints(Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6)


def main():
    try:
        Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6 = setup_matlab_vars()
        home_and_setup(Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6)
        cli_movement(Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6)

    finally:
        eng.meca1_ETC_Shotdown(adsClt, nargout=0)
        print("\nClosing MATLAB engine...")
        eng.quit()


if __name__ == '__main__':
    main()
