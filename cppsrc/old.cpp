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
        addr.netId = {192, 168, 0, 153, 1, 1}; // Ensuring it's correctly set
        addr.port = 851;


        long status = AdsSyncReadStateReq(&addr, nullptr);
        if (status != 0) {
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
