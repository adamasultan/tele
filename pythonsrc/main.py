import matlab.engine
import time
eng = matlab.engine.start_matlab()
eng.addpath("../matlabsrc", nargout=0)
adsClt = eng.start_ads_client()



def main():
    try:     
        Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6 = setup_matlab_vars()
        home_and_setup(Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6)
        print_joint_list(R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6)
        cli_movement(Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6)
    finally:
        eng.meca1_ETC_Shotdown(adsClt, nargout=0)
        print("Closing MATLAB engine...")
        eng.quit()
def matlab_global_vars():
    # Explicitly define Move_command in MATLAB
    eng.eval("global Move_command; Move_command = adsClt.ReadSymbolInfo('Main.Values');", nargout=0)
    

    # Initialize joint variables explicitly in MATLAB
    eng.eval("""
        global R1_j1 R1_j2 R1_j3 R1_j4 R1_j5 R1_j6;
        R1_j1 = adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Joint_Set.SubIndex_001');
        R1_j2 = adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Joint_Set.SubIndex_002');
        R1_j3 = adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Joint_Set.SubIndex_003');
        R1_j4 = adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Joint_Set.SubIndex_004');
        R1_j5 = adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Joint_Set.SubIndex_005');
        R1_j6 = adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Joint_Set.SubIndex_006');
    """, nargout=0)

def print_joint_list(R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6):
    R1_Joint = eng.meca1_GetJoints(adsClt, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6)

    # Display the joint positions
    rounded_list = [round(value, 2) for value in R1_Joint[0]]
    print(f"Current Joint Positions: {rounded_list}")
    
def cli_movement(Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6):
    print("Enter joint positions as space-separated values (e.g., '10 20 30 40 50 60'). Type 'exit' to quit.")
    while True:
        input_string = input("Enter joint positions: ").strip()
        if input_string.lower() == "exit":
            break
        try:
                # Convert input string to a list of floats
            float_array = []
            for val in input_string.split():
                try:
                        # Convert each value to float and append to the list
                    float_array.append(float(val))
                except ValueError:
                    print(f"Error: '{val}' is not a valid number.")
                    float_array = []  # Reset the list to avoid incorrect processing
                    break  # Exit loop on invalid input


                # Ensure the input has exactly 6 values
            if len(float_array) != 6:
                print("Error: Please enter exactly 6 joint values.")
                continue
            Jmovement = matlab.double([float_array])
                # Call the MATLAB function
            eng.meca1_MoveJoint(adsClt, Move_command, Jmovement, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6, nargout=0)
            print_joint_list(R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6)
        except ValueError:
            print("Error: Invalid input. Please enter space-separated numerical values.")

def home_and_setup(Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6):
    eng.meca1_ETC_Setup(adsClt, nargout=0)
    reset_joints(Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6)
    


def setup_matlab_vars():
    eng.workspace["adsClt"] = adsClt  # Store adsClt in MATLAB's workspace
    matlab_global_vars()
        

    Move_command = eng.workspace["Move_command"]  # Retrieve Move_command from MATLAB workspace    R1_j1 = eng.workspace["R1_j1"]
    R1_j1 = eng.workspace["R1_j1"]
    R1_j2 = eng.workspace["R1_j2"]
    R1_j3 = eng.workspace["R1_j3"]
    R1_j4 = eng.workspace["R1_j4"]
    R1_j5 = eng.workspace["R1_j5"]
    R1_j6 = eng.workspace["R1_j6"]
    return Move_command,R1_j1,R1_j2,R1_j3,R1_j4,R1_j5,R1_j6

def reset_joints(Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6):
    R1_Joint = eng.meca1_GetJoints(adsClt, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6)
    negative_joint_pose = R1_Joint[0]
    for i in range(len(negative_joint_pose)):
        negative_joint_pose[i]  = -R1_Joint[0][i]
    Jmovement = matlab.double([negative_joint_pose])
    eng.meca1_MoveJoint(adsClt, Move_command, Jmovement, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6, nargout=0)

if __name__ == '__main__':
    main()
    
