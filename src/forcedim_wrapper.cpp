#include "../forcedimension/sdk-3.17.6/include/dhdc.h"
#include "../forcedimension/sdk-3.17.6/include/drdc.h"
#include <iostream>

extern "C" {

    __declspec(dllexport) int initDevice(int ID) {
        dhdEnableExpertMode();
        dhdOpenID(ID);
        std::cout << "device successfully initialized" << std::endl << std::endl;
        return 0;
    }
    
    __declspec(dllexport) void closeDevice(int ID) {
        dhdClose(ID);
    }
    
    __declspec(dllexport) int getPose(double* x, double* y, double* z, double* oa, double* ob, double* og, int ID) {
        dhdGetPosition(x, y, z, ID);
        dhdGetOrientationDeg(oa, ob, og, ID);
        return 0;
    }
    }