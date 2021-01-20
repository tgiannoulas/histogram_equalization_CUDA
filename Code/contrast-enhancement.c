#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include "hist-equ.h"

PGM_IMG contrast_enhancement_g(PGM_IMG img_in)
{
    PGM_IMG result;
    int hist[256];
    //times
    struct timespec time_start, time_end;
    
    //Allocate memory
    result.w = img_in.w;
    result.h = img_in.h;
    result.img = (unsigned char *)malloc(result.w * result.h * sizeof(unsigned char));
    
    /*----------CPU COMPUTATION----------*/

    //time histogram
    clock_gettime(CLOCK_MONOTONIC_RAW, &time_start);
    histogram(hist, img_in.img, img_in.h * img_in.w, 256);
    clock_gettime(CLOCK_MONOTONIC_RAW, &time_end);
    printf ("CPU time = %15.10f seconds\n", time_format(time_start, time_end));

    //printf("CPU HISTOGRAM\n\n");
    //print_histogram(hist, 256);

    histogram_equalization(result.img,img_in.img,hist,result.w*result.h, 256);
    return result;
}