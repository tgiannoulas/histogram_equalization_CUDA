#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include "hist-equ.h"

void print_histogram(int *hist, int nbr_bin) {
    for ( int i = 0; i < nbr_bin; i ++){
        printf("hist[%d] = %d\n", i, hist[i]);
    }
}

void histogram_diff(int* hist_1, int* hist_2, int nbr_bin) {
    for (int i = 0; i < nbr_bin; i++) {
        if (hist_1[i] != hist_2[i]) {
            printf("Histograms are different\n");
            return;
        }
    }
    printf("Histograms are the same\n");
    return;
}

double time_format(struct timespec start, struct timespec end) {
	return ((double) (end.tv_nsec - start.tv_nsec) / 1000000000.0 +
		(double) (end.tv_sec - start.tv_sec));
}