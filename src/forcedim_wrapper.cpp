#include "../forcedimension/sdk-3.17.6/include/dhdc.h"
#include "../forcedimension/sdk-3.17.6/include/drdc.h"
#include <iostream>

extern "C" {

    __declspec(dllexport) int initDevice(char ID) {
        dhdOpenID(ID);
        // dhdSetBrakes(DHD_OFF, ID); // for loose movement
        return 0;
    }
    
    __declspec(dllexport) void closeDevice(char ID) {
        dhdClose(ID);
    }
    
    __declspec(dllexport) int getPose(double* x, double* y, double* z, double* oa, double* ob, double* og, char ID) {
        dhdSetDevice(ID);
        if (dhdGetPositionAndOrientationDeg(x, y, z, oa, ob, og, ID) < 0) return -1;
        return 0;
    }
    }