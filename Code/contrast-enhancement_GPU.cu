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

PGM_IMG contrast_enhancement_g_GPU(PGM_IMG h_img_in)
{
    PGM_IMG d_img_in, h_result, d_result;
    int *d_hist, *d_lut;
    //times
    struct timespec time_start, time_end;

    /*int h_hist[256];
    int hist_CPU[256];
    PGM_IMG result_CPU;
    result_CPU.w = h_img_in.w;
    result_CPU.h = h_img_in.h;
    result_CPU.img = (unsigned char *)malloc(h_img_in.w * h_img_in.h * sizeof(unsigned char));
    if (result_CPU.img == NULL) {
    	printf("%s, line: %d, cudaMalloc failed\n", __FILE__, __LINE__);
    	free_pgm(result_CPU);
    	free_pgm(h_img_in);
    	cudaDeviceReset();
		exit(1);
    }*/
    
    //Allocate host memory
    h_result.w = h_img_in.w;
    h_result.h = h_img_in.h;
    h_result.img = (unsigned char *)malloc(h_img_in.w * h_img_in.h * sizeof(unsigned char));
    //Allocate device memory
    cudaMalloc((void**)&d_img_in.img, h_img_in.w * h_img_in.h * sizeof(unsigned char));
    cudaMalloc((void**)&d_result.img, h_img_in.w * h_img_in.h * sizeof(unsigned char));
    cudaMalloc((void**)&d_hist, 256 * sizeof(int));
    cudaMalloc((void**)&d_lut, 256 * sizeof(int));
    if (d_img_in.img == NULL || d_result.img == NULL || d_hist == NULL || d_lut == NULL) {
    	printf("%s, line: %d, cudaMalloc failed\n", __FILE__, __LINE__);
    	free_memory(&h_img_in, &h_result, &d_img_in, &d_result, d_hist);
    	cudaDeviceReset();
		exit(1);
    }
    //Initialise device memory
    cudaMemcpy(d_img_in.img, h_img_in.img, h_img_in.w * h_img_in.h * sizeof(unsigned char), cudaMemcpyHostToDevice);
    cudaMemset(d_hist, 0, 256 * sizeof(int));
    
    /*----------GPU COMPUTATION----------*/

    //time histogram
    clock_gettime(CLOCK_MONOTONIC_RAW, &time_start);
    //Kernel with threads equal to pixels + the extra padding
    histogram_GPU<<<h_img_in.w * h_img_in.h / MAX_THREAD_IN_BLOCK + 1, MAX_THREAD_IN_BLOCK, 256 * sizeof(int)>>>
    	(d_hist, d_img_in.img, h_img_in.h * h_img_in.w, 256);
    clock_gettime(CLOCK_MONOTONIC_RAW, &time_end);
    cudaCheckError();
    printf ("GPU time = %15.10f seconds\n", time_format(time_start, time_end));
    
    //cudaMemcpy(h_hist, d_hist, 256 * sizeof(int), cudaMemcpyDeviceToHost);
    //printf("GPU HISTOGRAM\n\n");
    //print_histogram(h_hist, 256);
    //histogram(hist_CPU, h_img_in.img, h_img_in.h * h_img_in.w, 256);
    //printf("CPU HISTOGRAM\n\n");
    //print_histogram(hist_CPU, 256);
    //histogram_diff(h_hist, hist_CPU, 256);

    //time histogram equalization
    //clock_gettime(CLOCK_MONOTONIC_RAW, &time_start);
    histogram_lut_GPU<<<1, 1>>>
    	(d_hist, d_lut, h_img_in.w * h_img_in.h, 256);
    cudaCheckError();
    histogram_equalization_GPU<<<h_img_in.w * h_img_in.h / MAX_THREAD_IN_BLOCK + 1, MAX_THREAD_IN_BLOCK>>>
    	(d_result.img, d_img_in.img, d_lut, h_img_in.w * h_img_in.h);
    cudaCheckError();
    //clock_gettime(CLOCK_MONOTONIC_RAW, &time_end);
    //printf ("GPU time = %15.10f seconds\n", time_format(time_start, time_end));
    cudaMemcpy(h_result.img, d_result.img, h_img_in.w * h_img_in.h * sizeof(unsigned char), cudaMemcpyDeviceToHost);
    //CPU histogram equalization and diff
    //histogram_equalization(result_CPU.img, h_img_in.img, hist_CPU, h_img_in.w * h_img_in.h, 256);
    //img_diff(result_CPU, h_result);
    
    //free_pgm(result_CPU);
    cudaFree(d_img_in.img);
    cudaFree(d_result.img);
    cudaFree(d_hist);
    cudaDeviceReset();
    return h_result;
}
