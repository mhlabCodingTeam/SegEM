/**
 * \file watershit.c
 * \brief Meyer's watershed transform.
 * This algorithm segments a picture starting from a set of markers. The marker image
 * has to have a white background and each marker a different grey level.
 * @param image image to segment
 * @param marker image containing the markers
 * @param threshold threshold to which to flood
 * @return segmented-image the segmented image will be written to a file
 */

#include "mex.h"
#include <stdio.h>
#include <stdlib.h>

int **array_delims;
int **array;

unsigned long int NX, NY, NZ, THRESHOLD, N_LEVELS;
int *ARRAY_LENGTH;

/**
 * Dequeue a pixel from the array.
 * Get and remove the coordinates of the pixel with highest priority from the list and return its content.
 * @param color index of the array with the greylevel "color"
 * @return position the first element in the array (highest priority)
 */
int fifo_dequeue(int color)
{
    int position;
    if (array_delims[color][0] == array_delims[color][1]) return -1;

    position = array[color][array_delims[color][0]];
    array_delims[color][0] = (array_delims[color][0]+1) % ARRAY_LENGTH[color];
    return position;
}

/**
 * Enqueue a pixel to the array.
 * Add the position of a pixel to the end of the array.
 * @param color index of the array with the greylevel "color"
 * @param position the position of the pixel
 */
void fifo_queue(int color, int position)
{
    array[color][array_delims[color][1]] = position;
    array_delims[color][1] = (array_delims[color][1]+1) % ARRAY_LENGTH[color];
    //    mexPrintf("color: %d   position: %d   ARRAY_LENGTH[color]=%d      %d %d\n", color, position, ARRAY_LENGTH[color], array_delims[color][0], array_delims[color][1]);
}

void print_queues() {
    int i, a, b;
    int x, y, z, POS;
    for (i = 0; i < N_LEVELS; i++) {
        a = array_delims[i][0];
        b = array_delims[i][1];
        if (a == b) continue;
        mexPrintf("array[%d]  (%d, %d):  ", i, a, b);
        while (a != b) {
            POS = array[i][a];
            z = POS / (NX*NY);
            POS = POS % (NX*NY);
            x = POS % NX;
            y = POS / NX;
            mexPrintf("(%d,%d,%d) ", x, y, z);
            a = (a+1) % ARRAY_LENGTH[i];
        }
        mexPrintf("\n");
    }
}

/**
 * Watershit.
 * Segment an image using Meyer's flooding algorithm.
 * @param cnn_x
 * @param cnn_y
 * @param cnn_z
 * @param lab map with initial labels from which the flooding starts
 */
void watershit(unsigned short int *cnn_x, unsigned short int *cnn_y, unsigned short int *cnn_z, int *lab)
{
    int i, x, y, z, pos, POS, label;
    int new_i = 0;
    int empty = 0;
    int counter = 0;
    while (empty == 0) {
        for (i = 0; i <= THRESHOLD; i++) {
            while (array_delims[i][0] != array_delims[i][1]) {
                POS = fifo_dequeue(i);
                if (lab[POS] == -2) continue;
                pos = POS;
                z = pos / (NX*NY);
                pos = pos % (NX*NY);
                y = pos / NX;
                x = pos % NX;
                //mexPrintf("%d %d %d   ", x, y, z);
                label = 0;
                if (x-1 >= 0 && label != -2) {
                    pos = z*NX*NY + (x-1) + y*NX;
                    if (lab[pos] > 0) {
                        if (label == lab[pos] || label == 0) {
                            label = lab[pos];
                        } else {
                            label = -2;
                        }
                    } else if (lab[pos] == 0) {
                        fifo_queue(cnn_x[pos], pos);
                        lab[pos] = -1;
                    }
                }
                if (x+1 < NX && label != -2) {
                    pos = z*NX*NY + (x+1) + y*NX;
                    if (lab[pos] > 0) {
                        if (label == lab[pos] || label == 0) {
                            label = lab[pos];
                        } else {
                            label = -2;
                        }
                    } else if (lab[pos] == 0) {
                        fifo_queue(cnn_x[pos], pos);
                        lab[pos] = -1;
                    }
                }
                if (y-1 >= 0 && label != -2) {
                    pos = z*NX*NY + x + (y-1)*NX;
                    if (lab[pos] > 0) {
                        if (label == lab[pos] || label == 0) {
                            label = lab[pos];
                        } else {
                            label = -2;
                        }
                    } else if (lab[pos] == 0) {
                        fifo_queue(cnn_y[pos], pos);
                        lab[pos] = -1;
                    }
                }
                if (y+1 < NY && label != -2) {
                    pos = z*NX*NY + x + (y+1)*NX;
                    if (lab[pos] > 0) {
                        if (label == lab[pos] || label == 0) {
                            label = lab[pos];
                        } else {
                            label = -2;
                        }
                    } else if (lab[pos] == 0) {
                        fifo_queue(cnn_y[pos], pos);
                        lab[pos] = -1;
                    }
                }
                if (z-1 >= 0 && label != -2) {
                    pos = (z-1)*NX*NY + x + y*NX;
                    if (lab[pos] > 0) {
                        if (label == lab[pos] || label == 0) {
                            label = lab[pos];
                        } else {
                            label = -2;
                        }
                    } else if (lab[pos] == 0) {
                        fifo_queue(cnn_z[pos], pos);
                        lab[pos] = -1;
                    }
                }
                if (z+1 < NZ && label != -2) {
                    pos = (z+1)*NX*NY + x + y*NX;
                    if (lab[pos] > 0) {
                        if (label == lab[pos] || label == 0) {
                            label = lab[pos];
                        } else {
                            label = -2;
                        }
                    } else if (lab[pos] == 0) {
                        fifo_queue(cnn_z[pos], pos);
                        lab[pos] = -1;
                    }
                }
                if (label == 0) label = -2;
                lab[POS] = label;
                //mexPrintf("label = %d\n", label);
            }
        }
        empty = 1;
        for (i = 0; i <= THRESHOLD; i++) {
            if (array_delims[i][0] != array_delims[i][1]) {
                empty = 0;
                break;
            }
        }
    }
    //    mexPrintf("\n");
}


void init_priority_queues(unsigned short int *cnn_x, unsigned short int *cnn_y, unsigned short int *cnn_z)
{
    ARRAY_LENGTH = (int *) calloc(N_LEVELS, sizeof(int));
    int i;
    for (i = 0; i < NX*NY*NZ; i++) {
        ARRAY_LENGTH[cnn_x[i]] += 1;
        ARRAY_LENGTH[cnn_y[i]] += 1;
        ARRAY_LENGTH[cnn_z[i]] += 1;
        //        mexPrintf("%d %d %d\n", cnn_x[i], cnn_y[i], cnn_z[i]);
    }
    array = (int **) mxMalloc(N_LEVELS*sizeof(int *));
    array_delims = (int **) mxMalloc(N_LEVELS*sizeof(int *));
    for (i = 0; i < N_LEVELS; i++) {
        ARRAY_LENGTH[i] += 1;
        array[i] = (int *) mxMalloc( ARRAY_LENGTH[i] * sizeof(int) );
        //mexPrintf("%d - %d\n", i, ARRAY_LENGTH[i]);
        array_delims[i] = (int *) mxMalloc(2*sizeof(int));
        array_delims[i][0] = 0;
        array_delims[i][1] = 0;
    }
}

/**
 * mexFunction
 * Matlab routine should be called like this:
 * [labelled_image] = watershit(cnn_x, cnn_y, cnn_z, marker_image, n_levels, threshold);
 * cnn_x, cnn_y and cnn_z are images created by the CNN
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    int x, y, z, i, k, pos, POS;
    int *lab;
    unsigned short int *cnn_x;
    unsigned short int *cnn_y;
    unsigned short int *cnn_z;
    unsigned short int *markers;
    double *tmp;
    const mwSize *dim;

    dim = mxGetDimensions(prhs[0]);
    NX = dim[0];
    NY = dim[1];
    NZ = dim[2];

    //    mexPrintf("%d %d %d\n", NX, NY, NZ);

    cnn_x = (unsigned short int *) mxGetData(prhs[0]);
    cnn_y = (unsigned short int *) mxGetData(prhs[1]);
    cnn_z = (unsigned short int *) mxGetData(prhs[2]);
    markers = (unsigned short int *) mxGetData(prhs[3]);

    tmp = (double *) mxGetData(prhs[4]);
    N_LEVELS = (int) tmp[0];

    tmp = (double *) mxGetData(prhs[5]);
    THRESHOLD = (int) tmp[0];

    lab = (int *) mxMalloc(NX*NY*NZ*sizeof(int));
    init_priority_queues(cnn_x, cnn_y, cnn_z);

    for (i = 0; i < NX*NY*NZ; i++) {
        lab[i] = markers[i];
    }

    //mexPrintf("\n\n");
    for (z = 0; z < NZ; z++) {
        for (y = 0; y < NY; y++) {
            for (x = 0; x < NX; x++) {
                POS = z*NX*NY + x + y*NX;
                if (lab[POS] <= 0) continue;
                //mexPrintf("%d %d %d\n", x, y, z);
                if (x-1 >= 0) {
                    pos = z*NX*NY + (x-1) + y*NX;
                    if (lab[pos] == 0) {
                        fifo_queue(cnn_x[pos], pos);
                        lab[pos] = -1;
                    }
                }
                if (x+1 < NX) {
                    pos = z*NX*NY + (x+1) + y*NX;
                    if (lab[pos] == 0) {
                        fifo_queue(cnn_x[pos], pos);
                        lab[pos] = -1;
                    }
                }
                if (y-1 >= 0) {
                    pos = z*NX*NY + x + (y-1)*NX;
                    if (lab[pos] == 0) {
                        fifo_queue(cnn_y[pos], pos);
                        lab[pos] = -1;
                    }
                }
                if (y+1 < NY) {
                    pos = z*NX*NY + x + (y+1)*NX;
                    if (lab[pos] == 0) {
                        fifo_queue(cnn_y[pos], pos);
                        lab[pos] = -1;
                    }
                }
                if (z-1 >= 0) {
                    pos = (z-1)*NX*NY + x + y*NX;
                    if (lab[pos] == 0) {
                        fifo_queue(cnn_z[pos], pos);
                        lab[pos] = -1;
                    }
                }
                if (z+1 < NZ) {
                    pos = (z+1)*NX*NY + x + y*NX;
                    if (lab[pos] == 0) {
                        fifo_queue(cnn_z[pos], pos);
                        lab[pos] = -1;
                    }
                }
            }
            //            mexPrintf("\n");
        }
        //         mexPrintf("\n\n");
    }

    //print_queues();
    //    return;
    watershit(cnn_x, cnn_y, cnn_z, lab);
    //print_queues();

    plhs[0] = (mxArray *) mxCreateNumericArray(3, dim, mxUINT16_CLASS, mxREAL);
    markers = (unsigned short int *) mxGetData(plhs[0]);
    for (i = 0; i < NX*NY*NZ; i++) {
        //        mexPrintf("%d ", lab[i]);        
        if (lab[i] >= 0) {
            markers[i] = (unsigned short int) lab[i];
        } else {
            //        markers[i] = 0;
        }
    }
    for (i = 0; i < N_LEVELS; i++) {
        mxFree(array[i]);
        mxFree(array_delims[i]);
    }
    mxFree(array);
    mxFree(array_delims);
    mxFree(lab);
}
