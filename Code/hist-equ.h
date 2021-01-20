#ifndef HIST_EQU_COLOR_H
#define HIST_EQU_COLOR_H

#define MAX_THREAD_DIM 32
#define MAX_THREAD_IN_BLOCK (MAX_THREAD_DIM*MAX_THREAD_DIM)
#define cudaCheckError() {                                                                       \
			cudaError_t e=cudaGetLastError();                                                    \
			if(e!=cudaSuccess) {                                                                 \
				printf("Cuda failure %s:%d: '%s'\n",__FILE__,__LINE__,cudaGetErrorString(e));    \
				free_memory(&img_in, &result, &d_img_in, &d_result, d_hist);                     \
				cudaDeviceReset();                                                               \
				exit(EXIT_FAILURE);                                                              \
			}                                                                                    \
		}

typedef struct{
    int w;
    int h;
    unsigned char * img;
} PGM_IMG;

//main.c
PGM_IMG read_pgm(const char * path);
void write_pgm(PGM_IMG img, const char * path);
void free_pgm(PGM_IMG img);

//histogram-equalization.c
void histogram(int * hist_out, unsigned char * img_in, int img_size, int nbr_bin);
void histogram_equalization(unsigned char * img_out, unsigned char * img_in, 
                            int * hist_in, int img_size, int nbr_bin);

//Contrast enhancement for gray-scale images
//contrast_enhancement.c
PGM_IMG contrast_enhancement_g(PGM_IMG img_in);
//contrast_enhancement_GPU.cu
PGM_IMG contrast_enhancement_g_GPU(PGM_IMG img_in);

//util.c
void print_histogram(int *hist, int nbr_bin);
void histogram_diff(int* hist_1, int* hist_2, int nbr_bin);
double time_format(struct timespec start, struct timespec end);

#endif
