#include "../forcedimension/sdk-3.17.6/include/dhdc.h"
#include "../forcedimension/sdk-3.17.6/include/drdc.h"
#include <iostream>

extern "C" {

    __declspec(dllexport) int initDevice(char ID) {
        dhdOpenID(ID);
        // dhdSetGravityCompensation(DHD_ON);
        return 0;
    }
    
    __declspec(dllexport) void closeDevice(char ID) {
        dhdClose(ID);
    }
    
    __declspec(dllexport) int getPose(double* x, double* y, double* z, double* oa, double* ob, double* og, char ID) {
        
        if (dhdGetPosition(x, y, z, ID) < 0) return -1;
        if (dhdGetOrientationDeg(oa, ob, og, ID) < 0) return -2;
        return 0;
    }
    }