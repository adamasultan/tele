#include "../forcedimension/sdk-3.17.6/include/dhdc.h"
#include "../forcedimension/sdk-3.17.6/include/drdc.h"
#include <iostream>

extern "C" {

    __declspec(dllexport) int initDevice() {
        return dhdOpen();
    }
    
    __declspec(dllexport) void closeDevice() {
        dhdClose();
    }
    
    __declspec(dllexport) int getPose(double* x, double* y, double* z, double* oa, double* ob, double* og) {
        if (dhdGetPosition(x, y, z) < 0) return -1;
        if (dhdGetOrientationDeg(oa, ob, og) < 0) return -2;
        return 0;
    }
    }