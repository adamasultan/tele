#include <iostream>
#include <windows.h>  // Required for BOOL definition
#include "C:/TwinCAT/AdsApi/TcAdsDll/Include/TcAdsDef.h"
#include "C:/TwinCAT/AdsApi/TcAdsDll/Include/TcAdsAPI.h"

// Define BOOL explicitly to fix missing declaration error
typedef int BOOL;

class Meca500Controller {
private:
    long port;
    AmsAddr addr;

public:
    Meca500Controller() {
        port = AdsPortOpen();
        AdsGetLocalAddress(&addr);

        // Correct AMS Net ID assignment
        addr.netId.b[0] = 192;
        addr.netId.b[1] = 168;
        addr.netId.b[2] = 0;
        addr.netId.b[3] = 153;
        addr.netId.b[4] = 1;
        addr.netId.b[5] = 1;
        addr.port = 851;
    }

    ~Meca500Controller() {
        AdsPortClose();
    }

    void setupRobot() {
        int activate = 1;
        AdsSyncWriteReq(&addr, 0x4020, 0, sizeof(activate), &activate);
        std::cout << "Robot activated." << std::endl;
    }

    void moveToPosition(float x, float y, float z, float rx, float ry, float rz) {
        float values[6] = {x, y, z, rx, ry, rz};
        AdsSyncWriteReq(&addr, 0x4020, 1, sizeof(values), values);
        std::cout << "Moving to position: " << x << ", " << y << ", " << z << std::endl;
    }

    void shutdownRobot() {
        int deactivate = 1;
        AdsSyncWriteReq(&addr, 0x4020, 2, sizeof(deactivate), &deactivate);
        std::cout << "Robot deactivated." << std::endl;
    }
};

int main() {
    Meca500Controller robot;
    robot.setupRobot();

    while (true) {
        float x, y, z, rx, ry, rz;
        std::cout << "Enter position values (x y z rx ry rz) or -1 to exit: ";
        std::cin >> x;
        if (x == -1) break;
        std::cin >> y >> z >> rx >> ry >> rz;
        robot.moveToPosition(x, y, z, rx, ry, rz);
    }

    robot.shutdownRobot();
    return 0;
}
