import matlab.engine

try:
    # Start MATLAB engine
    eng = matlab.engine.start_matlab()
    eng.addpath("../matlabsrc", nargout=0)  # Adjust the path

    # Run a MATLAB script (ensure the script is in MATLAB's path)
    adsClt = eng.start_ads_client()
    eng.meca1_ETC_Setup(adsClt, nargout=0)
    eng.meca1_ETC_Shotdown(adsClt, nargout=0)

    print("Robot setup completed.")

finally:
    print("Closing MATLAB engine...")
    eng.quit()
