//---------------------------------------------------------------------------------------------------------------------
//
//---------------------------------------------------------------------------------------------------------------------
#include <cuda.h>
#include <cuda_runtime.h>
#include <exception>
#include <iostream>

int main(int, char**)
{
    try
    {
        int deviceCount = 0;
        cudaError_t error_id = cudaGetDeviceCount(&deviceCount);
        if (error_id != cudaSuccess)
        {
            std::cerr << "cudaGetDeviceCount returned " << static_cast<int>(error_id) << ".\n"
                      << " -> " << cudaGetErrorString(error_id) << "\n";
            exit(EXIT_FAILURE);
        }

        std::cout << "Detected " << deviceCount << " CUDA capable device(s)\n";
    }
    catch (const std::exception& ex)
    {
        std::cerr << "Exception: " << ex.what();
    }
}
