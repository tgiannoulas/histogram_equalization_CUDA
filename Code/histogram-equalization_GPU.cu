#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "hist-equ.cu.h"

extern "C"{
#include "hist-equ.h"
}

__device__ void print_id() {
    printf("by: %d, bx: %d, tx: %d, ty: %d\n", blockIdx.y, blockIdx.x, threadIdx.y, threadIdx.x);
    return;
}

__global__ void histogram_GPU(int * hist_out, unsigned char * img_in, int img_size, int nbr_bin) {

    int pixel = blockIdx.x * blockDim.x + threadIdx.x;
    
    if (pixel < img_size) {
        atomicAdd(&hist_out[img_in[pixel]], 1);
    }
}

__global__ void histogram_lut_GPU(int * hist_in, int * lut, int img_size, int nbr_bin) {

    int pixel, i, cdf, min, d;
    pixel = blockIdx.x * blockDim.x + threadIdx.x;

    /* Construct the LUT by calculating the CDF */
    if (pixel == 0) {
        cdf = 0;
        min = 0;
        i = 0;
        while (min == 0) {
            min = hist_in[i++];
        }
        d = img_size - min;
        for (i = 0; i < nbr_bin; i ++) {
            cdf += hist_in[i];
            //lut[i] = (cdf - min)*(nbr_bin - 1)/d;
            lut[i] = (int)(((float)cdf - min)*255/d + 0.5);
            if (lut[i] < 0) {
                lut[i] = 0;
            }
            else if (lut[i] > 255) {
                lut[i] = 255;
            }
        }
    }
}

__global__ void histogram_equalization_GPU(unsigned char * img_out, unsigned char * img_in, 
                            int * lut, int img_size) {
    
    int pixel;
    pixel = blockIdx.x * blockDim.x + threadIdx.x;

    /* Get the result image */
    if (pixel < img_size) {
        img_out[pixel] = (unsigned char)lut[img_in[pixel]];
    }
}
