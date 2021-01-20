#ifndef HIST_EQU_COLOR_GPU_H
#define HIST_EQU_COLOR_GPU_H

__global__ void histogram_GPU(int * hist_out, unsigned char * img_in, int img_size, int nbr_bin);
__global__ void histogram_equalization_GPU(unsigned char * img_out, unsigned char * img_in, 
                            int * hist_in, int img_size, int nbr_bin);

#endif
