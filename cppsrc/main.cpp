#include <iostream>
#include "MatlabEngine.hpp"
#include "MatlabDataArray.hpp"

using namespace matlab::engine;
using namespace matlab::data;

int main() {
    try {
        std::cout << "Starting MATLAB Engine...\n";

        // Start MATLAB Engine
        std::unique_ptr<MATLABEngine> matlabPtr = startMATLAB();
        std::cout << "MATLAB Engine started successfully.\n";

        // Add path to MATLAB scripts
        matlabPtr->eval(u"addpath('C:/Users/biom-admin/teleoperation/hapticteleoperation/matlabsrc')");
        std::cout << "MATLAB path added.\n";

        std::cout << "Enter position values (x y z rx ry rz) or -1 to exit:\n";
        
        while (true) {
            double x, y, z, rx, ry, rz;
            std::cin >> x;
            if (x == -1) break;
            std::cin >> y >> z >> rx >> ry >> rz;

            // Create MATLAB array to store position values
            ArrayFactory factory;
            TypedArray<double> positionArray = factory.createArray<double>({1, 6}, {x, y, z, rx, ry, rz});

            // Call MATLAB function
            try {
                matlabPtr->feval(u"meca1_SetPos", 0, {positionArray});
                std::cout << "Moved to position: " << x << ", " << y << ", " << z << "\n";
            } catch (const matlab::engine::MATLABException& e) {
                std::cerr << "MATLAB function error: " << e.what() << std::endl;
            }
        }


    } catch (const matlab::engine::EngineException& e) {
        std::cerr << "MATLAB Engine Error: " << e.what() << std::endl;
    }

    std::cout << "Shutting down MATLAB Engine...\n";
    return 0;
}
