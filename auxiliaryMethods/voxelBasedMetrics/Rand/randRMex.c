/* RANDRMEX.CPP Use to calculate the crucial stage of the rand error in Matlab
Syntax: [ err, N ] = randRMex( gT, seg, rMin, rMax, [xMin, xMax], [yMin, yMax], [zMin, zMax] );
Because of the boundaries in the size of gT and seg, one can use this code in parallel
The input arguments gT and seg need to be three dimensional and double */

#include "mex.h"
#include <math.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	/* Macros for the ouput and input arguments */
	#define Err_OUT plhs[0]
	#define N_OUT plhs[1]
	#define GT_IN prhs[0]
	#define Seg_IN prhs[1]
	#define R1_IN prhs[2]
	#define R2_IN prhs[3]
	#define N_IN prhs[4]
	#define M_IN prhs[5]
	#define P_IN prhs[6]

	/* Initialize all variables */
	double *seg, *gT, *err, *N, *R1, *R2, thisSeg, thisGT;
	int *n, *m, *p, N1, M1, P1, i, j, k, ii, jj, kk, rMax, s;

	R1 = mxGetPr(R1_IN); /* Get the pointer to R1_IN */
	R2 = mxGetPr(R2_IN); /* Get the pointer to R2_IN */

	const mwSize *gTDim = mxGetDimensions(GT_IN); /* Get the dimensions of GT_IN */
	N1 = gTDim[0];
	M1 = gTDim[1];
	P1 = gTDim[2];	

	n = (int *)mxGetData(N_IN); /* Get the pointer to N_IN */
	m = (int *)mxGetData(M_IN); /* Get the pointer to M_IN */
	p = (int *)mxGetData(P_IN); /* Get the pointer to P_IN */

	gT = mxGetPr(GT_IN); /* Get the pointer to the data of gT */
	seg = mxGetPr(Seg_IN); /* Get the pointer to the data of seg */

	Err_OUT = mxCreateDoubleScalar(0); /* Create the output scalar */
	err = mxGetPr(Err_OUT); /* Get the pointer to the data of Err_OUT */
	N_OUT = mxCreateDoubleScalar(0); /* Create the output scalar */
	N = mxGetPr(N_OUT); /* Get the pointer to the data of N_OUT */
	err[0] = 0.0;
	N[0] = 0.0;

	rMax = ceil(R2[0]); /* In the for loop, R2 is used. Use ceil, to avoid problems with non-integer R2. */

	if ((rMax < N1) || (rMax < M1) || (rMax < P1) || (R1[0] > 0.0))
	{
		/* Check all elements in the neighbourhood (R1 < r <= R2) in pairs for faulty connections.
		All connections are counted twice, but this cancels in the final quotient err / N. */
		for (i = n[0]; i < n[1]; i++)
		{
			for (j = m[0]; j < m[1]; j++)
			{
				for (k = p[0]; k < p[1]; k++)
				{
					thisGT = gT[i + N1 * (j + M1 * k)];
					thisSeg = seg[i + N1 * (j + M1 * k)];

					/* Search in the cube around the current position with length 2*R2 for those with the correct distance. */
					for (ii = max(0, i - rMax); ii < min(N1, i + rMax + 1); ii++)
					{
						for (jj = max(0, j - rMax); jj < min(M1, j + rMax + 1); jj++)
						{
							for (kk = max(0, k - rMax); kk < min(P1, k + rMax + 1); kk++)
							{
								double dist = (ii - i) * (ii - i) + (jj - j) * (jj - j) + (kk - k) * (kk - k);

								/* Pick the correct range in distance. */
								if ((sqrt(dist) > R1[0]) && (sqrt(dist) <= R2[0]))
								{
									/* Count all the connections */
									N[0] += 1;

									/* Then count those connections which are different ( |delta(S_i, S_j) - delta(T_i, T_j)| ). */
									if ((seg[ii + N1 * (jj + M1 * kk)] != thisSeg) || (gT[ii + N1 * (jj + M1 * kk)] != thisGT))
									{
										if ((seg[ii + N1 * (jj + M1 * kk)] == thisSeg) || (gT[ii + N1 * (jj + M1 * kk)] == thisGT))
											err[0] += 1;
									}
								}
							}
						}
					}
				}
			}
		}
	}
	else
	{
		/* Check all elements with pairwise connections to all other elements in the cube.
		All connections are counted once. */
        int nSize = N1 * M1 * P1;
		for (i = n[0]; i < n[1]; i++)
		{
			for (j = m[0]; j < m[1]; j++)
			{
				for (k = p[0]; k < p[1]; k++)
				{
					int a = i + N1 * (j + M1 * k);
					thisGT = gT[a];
					thisSeg = seg[a];

					for (s = a + 1; s < nSize; s++)
					{
						/* Count all the connections */
						N[0] += 1;

						/* Then count those connections which are different ( |delta(S_i, S_j) - delta(T_i, T_j)| ). */
						if ((seg[s] != thisSeg) || (gT[s] != thisGT))
						{
							if ((seg[s] == thisSeg) || (gT[s] == thisGT))
								err[0] += 1;
						}
					}
				}
			}
		}
	}
	return;
}