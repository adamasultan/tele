#include <iostream>
#include <windows.h>  // Required for BOOL definition
#include "C:/TwinCAT/AdsApi/TcAdsDll/Include/TcAdsDef.h"
#include "C:/TwinCAT/AdsApi/TcAdsDll/Include/TcAdsAPI.h"

typedef int BOOL;

class Meca500Controller {
private:
    long port;
    AmsAddr addr;

public:
    Meca500Controller() {
        port = AdsPortOpenEx();
        if (port <= 0) {
            std::cout << "Failed to open ADS port!" << std::endl;
            return;
        }
        
        AdsGetLocalAddress(&addr);
        addr.netId.b[0] = 192;
        addr.netId.b[1] = 168;
        addr.netId.b[2] = 0;
        addr.netId.b[3] = 153;
        addr.netId.b[4] = 1;  // FIXED AMS Net ID
        addr.netId.b[5] = 1;  // FIXED AMS Net ID
        addr.port = 851;

        long status = AdsSyncReadReq(&addr, ADSIGRP_SYM_VERSION, 0, 0, nullptr);
        if (status == 0) {
            std::cout << "ADS connection established!" << std::endl;
        } else {
            std::cout << "ADS connection failed! Error: " << status << std::endl;
        }
    }

    ~Meca500Controller() {
        AdsPortClose();
    }
};

int main() {
    Meca500Controller robot;
    return 0;
}
