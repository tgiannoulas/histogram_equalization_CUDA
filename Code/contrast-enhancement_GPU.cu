#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
extern "C"{
#include "hist-equ.h"
}
#include "hist-equ.cu.h"

void free_memory(PGM_IMG *img1, PGM_IMG *img2, PGM_IMG *img3, PGM_IMG *img4, int *img5) {
	free_pgm(*img1);
	free_pgm(*img2);
	cudaFree(img3->img);
	cudaFree(img4->img);
	cudaFree(img5);
}

PGM_IMG contrast_enhancement_g_GPU(PGM_IMG img_in)
{
    PGM_IMG d_img_in, result, d_result;
    int hist[256], *d_hist;
    //times
    struct timespec time_start, time_end;

    int hist_CPU[256];
    
    //Allocate host memory
    result.w = img_in.w;
    result.h = img_in.h;
    result.img = (unsigned char *)malloc(result.w * result.h * sizeof(unsigned char));
    //Allocate device memory
    cudaMalloc((void**)&d_img_in.img, img_in.w * img_in.h * sizeof(unsigned char));
    cudaMalloc((void**)&d_result.img, img_in.w * img_in.h * sizeof(unsigned char));
    cudaMalloc((void**)&d_hist, 256 * sizeof(int));
    if (d_img_in.img == NULL || d_result.img == NULL || d_hist == NULL) {
    	printf("%s, line: %d, cudaMalloc failed\n", __FILE__, __LINE__);
    	free_memory(&img_in, &result, &d_img_in, &d_result, d_hist);
    	cudaDeviceReset();
		exit(-1);
    }
    //Initialise device memory
    cudaMemcpy(d_img_in.img, img_in.img, img_in.w * img_in.h * sizeof(unsigned char), cudaMemcpyHostToDevice);
    cudaMemset(d_hist, 0, 256 * sizeof(int));
    
    /*----------GPU COMPUTATION----------*/

    //time histogram
    clock_gettime(CLOCK_MONOTONIC_RAW, &time_start);
    //Kernel with threads equal to pixels + the extra padding
    histogram_GPU<<<img_in.w * img_in.h / MAX_THREAD_IN_BLOCK + 1, MAX_THREAD_IN_BLOCK>>>
    	(d_hist, d_img_in.img, img_in.h * img_in.w, 256);
    clock_gettime(CLOCK_MONOTONIC_RAW, &time_end);
    cudaCheckError();
    printf ("GPU time = %15.10f seconds\n", time_format(time_start, time_end));
    //printf("GPU HISTOGRAM\n\n");
    //print_histogram(hist, 256);
    //CPU histogram and diff
    //histogram(hist_CPU, img_in.img, img_in.h * img_in.w, 256);
    //histogram_diff(hist, hist_CPU, 256);


    histogram_equalization_GPU<<<1, 4>>>(d_result.img,d_img_in.img,hist,result.w*result.h, 256);

    cudaMemcpy(hist, d_hist, 256 * sizeof(int), cudaMemcpyDeviceToHost);

    cudaDeviceReset();
    return result;
}
