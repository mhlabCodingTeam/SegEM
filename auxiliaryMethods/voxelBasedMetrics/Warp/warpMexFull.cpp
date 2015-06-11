/* WARPMEXFULL2.CPP Use to calculate warping in Matlab
Syntax: warping = warpMexFull( gT, analogue );
The input arguments gT and analogue need to be three dimensional and double */

#include "mex.h"
//#include "C:\Program Files\MATLAB\R2014a\extern\include\mex.h"

//#include <math.h>
//#include <vector>
//using namespace std;


/* Function used to visit all zeros recursively starting from a given point (26-adjacency). */
void visit1(int a, int b, int c, const int *n, const int *m, const int *p, int *neigh, int *visited)
{
	for (int i = max(0, a - 1); i < min(n[0], a + 2); i++)
	{
		for (int j = max(0, b - 1); j < min(m[0], b + 2); j++)
		{
			for (int k = max(0, c - 1); k < min(p[0], c + 2); k++)
			{
				if ((neigh[i + n[0] * (j + m[0] * k)] == 0) && (visited[i + n[0] * (j + m[0] * k)] == 0))
				{
					visited[i + n[0] * (j + m[0] * k)] = 1;
					visit1(i, j, k, n, m, p, neigh, visited);
					return;
				}
			}

		}
	}
}

/* Function used to visit all ones recursively starting from a given point (6-adjacency). */
void visit2(int a, int b, int c, const int *n, const int *m, const int *p, int *neigh, int *visited)
{
	if ((neigh[max(0, a - 1) + n[0] * (b + m[0] * c)] == 1) && (visited[max(0, a - 1) + n[0] * (b + m[0] * c)] == 0))
	{
		visited[max(0, a - 1) + n[0] * (b + m[0] * c)] = 1;
		visit2(max(0, a - 1), b, c, n, m, p, neigh, visited);
	}
	if ((neigh[min(n[0], a + 1) + n[0] * (b + m[0] * c)] == 1) && (visited[min(n[0], a + 1) + n[0] * (b + m[0] * c)] == 0))
	{
		visited[min(n[0], a + 1) + n[0] * (b + m[0] * c)] = 1;
		visit2(min(n[0], a + 1), b, c, n, m, p, neigh, visited);
	}
	if ((neigh[a + n[0] * (max(0, b - 1) + m[0] * c)] == 1) && (visited[a + n[0] * (max(0, b - 1) + m[0] * c)] == 0))
	{
		visited[a + n[0] * (max(0, b - 1) + m[0] * c)] = 1;
		visit2(a, max(0, b - 1), c, n, m, p, neigh, visited);
	}
	if ((neigh[a + n[0] * (min(m[0], b + 1) + m[0] * c)] == 1) && (visited[a + n[0] * (min(m[0], b + 1) + m[0] * c)] == 0))
	{
		visited[a + n[0] * (min(m[0], b + 1) + m[0] * c)] = 1;
		visit2(a, min(m[0], b + 1), c, n, m, p, neigh, visited);
	}
	if ((neigh[a + n[0] * (b + m[0] * max(0, c - 1))] == 1) && (visited[a + n[0] * (b + m[0] * max(0, c - 1))] == 0))
	{
		visited[a + n[0] * (b + m[0] * max(0, c - 1))] = 1;
		visit2(a, b, max(0, c - 1), n, m, p, neigh, visited);
	}
	if ((neigh[a + n[0] * (b + m[0] * min(p[0], c + 1))] == 1) && (visited[a + n[0] * (b + m[0] * min(p[0], c + 1))] == 0))
	{
		visited[a + n[0] * (b + m[0] * min(p[0], c + 1))] = 1;
		visit2(a, b, min(p[0], c + 1), n, m, p, neigh, visited);
	}
	return;
}

/* Function to test whether a given point in its neighbourhood is simple,
i.e. whether the number of foreground and background connected components
is exactly one. For the foreground, 6-adjacency is used, for the background
26-adjaceny. */
int testIsSimple(int *neigh, const int n, const int m, const int p)
{
	int i, j, k;
	int s0 = 0;
	int s1 = 0;

	/* s1 = Number of Ones in the neighbourhood */
	for (i = 0; i < (n * m * p); i++)
		s1 += neigh[i];

	/* s0 = Number of Zeros in the neighbourhood */
	s0 = n * m * p - s1;

	if ((s0 == 0) || (s1 == 0))
		return 0;

	if ((s0 == 1) || (s1 == 1))
		return 1;

	/* If center == 0, then there is exactly one connected component in the
	background. Center is only defined, if n == m == p == 3. */
	int n2;
	int* visited = new int[n * m * p];

	if (((n + m + p) == 9) && (neigh[26] == 0)) /* 26 = 2 + 3 * ( 2 + 3 * 2 ) == neigh[2, 2, 2] */
	{
		n2 = s0;
	}

	/* Use a matrix visited. Start with finding a point, that has the value zero (must exist, as s0 > 0).
	Then "visit" all points, that can be reached from this point, based on the adjacency. */
	else
	{
		/* Initialize */
		for (i = 0; i < (n * m * p); i++)
			visited[i] = 0;

		int br = 0;

		for (i = 0; ((i < n) && (br == 0)); i++)
		{
			for (j = 0; ((j < m) && (br == 0)); j++)
			{
				for (k = 0; ((k < p) && (br == 0)); k++)
				{
					if (neigh[i + n * (j + m * k)] == 0)
					{
						visited[i + n * (j + m * k)] = 1;
						visit1(i, j, k, &n, &m, &p, neigh, visited);
						br = 1;
					}
				}

			}
		}

		/* Now check, whether the number of zeros and the number of visited zeros is
		the same (then we have only one connected component in the background). */
		n2 = 0;
		for (i = 0; i < (n * m * p); i++)
			n2 += visited[i];
	}

	/* If exactly one connected component in background, test foreground */
	if (n2 == s0)
	{
		/* Initialize */
		for (i = 0; i < (n * m * p); i++)
			visited[i] = 0;

		/* Use a matrix visited. Start with finding a point, that has the value one (must exist, as s1 > 0).
		Then "visit" all points, that can be reached from this point, based on the adjacency. */
		int br = 0;
		for (i = 0; ((i < n) && (br == 0)); i++)
		{
			for (j = 0; ((j < m) && (br == 0)); j++)
			{
				for (k = 0; ((k < p) && (br == 0)); k++)
				{
					if (neigh[i + n * (j + m * k)] == 1)
					{
						visited[i + n * (j + m * k)] = 1;
						visit2(i, j, k, &n, &m, &p, neigh, visited);
						br = 1;
					}
				}

			}
		}

		/* Now check, whether the number of ones and the number of visited oness is
		the same (then we have only one connected component in the foreground). */
		n2 = 0;
		for (i = 0; i < (n * m * p); i++)
			n2 += visited[i];

		/* If exactly one connected component in foreground, then simple */
		if (n2 == s1)
			return 1;
	}

	delete[] visited; /* Delete visited again */

	return 0;
}


/* Main function */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	/* Macros for the ouput and input arguments */
	#define WARPING_OUT plhs[0]
	#define GT_IN prhs[0]
	#define ANALOGUE_IN prhs[1]

	/* Initialize all variables */
	double *warping, *gT, *analogue;
	int n, m, p, i, j, k, ii, jj, kk;

	const mwSize *gTDim = mxGetDimensions(GT_IN); /* Get the dimensions of GT_IN */
	n = gTDim[0];
	m = gTDim[1];
	p = gTDim[2];

	gT = mxGetPr(GT_IN); /* Get the pointer to the data of gT */
	analogue = mxGetPr(ANALOGUE_IN); /* Get the pointer to the data of analogue */

	/* Copy data of gT into warping. */
	WARPING_OUT = mxCreateNumericMatrix(0, 0, mxDOUBLE_CLASS, mxREAL);
	mxSetDimensions(WARPING_OUT, mxGetDimensions(GT_IN), mxGetNumberOfDimensions(GT_IN));
	mxSetData(WARPING_OUT, mxMalloc(sizeof(double)* mxGetNumberOfElements(GT_IN)));
	warping = mxGetPr(WARPING_OUT);
	for (i = 0; i < (n * m * p); i++)
	{
		warping[i] = gT[i];
	}

	/* S: -1 == not in mask, 0 == non-simple, 1 == simple */
	int* S = new int[n * m * p]; /* size needs to be known at runtime */

	/* Firstly, only consider point within the mask (euclidean distance 5 of background) */
	for (i = 0; i < n; i++)
	{
		for (j = 0; j < m; j++)
		{
			for (k = 0; k < p; k++)
			{
				int cond = 0;

				/* Check for all points, whether they belong to the mask (cond == 1).
				These are all points within euclidean distance 5 of the background. */
				if (gT[i + n * (j + m * k)] == 0)
					cond = 1;
				else
				{
					int br = 1;
					int r = 5;
					for (ii = max(0, i - r); ((ii < min(n, i + r + 1)) && (br == 1)); ii++)
					{
						for (jj = max(0, j - r); ((jj < min(m, j + r + 1)) && (br == 1)); jj++)
						{
							for (kk = max(0, k - r); ((kk < min(p, k + r + 1)) && (br == 1)); kk++)
							{
								double dist = (ii - i) ^ 2 + (jj - j) ^ 2 + (kk - k) ^ 2;
								if (sqrt(dist) <= r)
								{
									if (gT[ii + n * (jj + m * kk)] == 0)
									{
										cond = 1;
										br = 0;
									}
								}
							}
						}
					}
				}

				/* Now look whether the point in the mask is simple. */
				if (cond == 1)
				{
					/* Copy the neighbourhood of the point into a new array, so that its simpleness can be determined. */
					const int nStart = max(0, i - 1);
					const int nEnd = min(n, i + 2);
					const int mStart = max(0, j - 1);
					const int mEnd = min(m, j + 2);
					const int pStart = max(0, k - 1);
					const int pEnd = min(p, k + 2);
					const int n1 = nEnd - nStart;
					const int m1 = mEnd - mStart;
					const int p1 = pEnd - pStart;

					int* part = new int[n1 * m1 * p1]; /* size needs to be known at runtime */

					for (ii = nStart; ii < nEnd; ii++)
					{
						for (jj = mStart; jj < mEnd; jj++)
						{
							for (kk = pStart; kk < pEnd; kk++)
							{
								part[(ii - nStart) + n1 * ((jj - mStart) + m1 * (kk - pStart))] = gT[ii + n * (jj + m * kk)];
							}
						}
					}

					if (testIsSimple(part, n1, m1, p1) == 1)
					{
						S[i + n * (j + m * k)] = 1;
					}
					else
					{
						S[i + n * (j + m * k)] = 0;
					}

					/* Delete part */
					delete[] part;
				}
				else
				{
					S[i + n * (j + m * k)] = -1;
				}
			}
		}
	}

	/* Now start the actual warping process. */
	while (1)
	{
		/* Find the simple point, that has the strongest difference to the analogue image. */
		double indMax = 0;
		int ind = 0;
		for (i = 0; i < (n * m * p); i++)
		{
			if ((S[i] == 1) && (indMax < abs(warping[i] - analogue[i])))
			{
					ind = i;
					indMax = abs(warping[i] - analogue[i]);
			}
		}

		ii = ind % n;
		jj = ((ind - ii) / n) % m;
		kk = (((ind - ii) / n) - jj) / m;

		/* Change its value accordingly. If a change is not beneficial, then stop the warping process.*/
		if (0.5 < indMax)
			warping[ind] = 1 - warping[ind];
		else
			return;

		/* Check for changes in simple points */
		for (i = max(0, ii - 1); i < min(n, ii + 2); i++)
		{
			for (j = max(0, jj - 1); j < min(m, jj + 2); j++)
			{
				for (k = max(0, kk - 1); k < min(p, kk + 2); k++)
				{
					/* Copy the neighbourhood of the point into a new array, so that its simpleness can be determined. */
					const int nStart = max(0, i - 1);
					const int nEnd = min(n, i + 2);
					const int mStart = max(0, j - 1);
					const int mEnd = min(m, j + 2);
					const int pStart = max(0, k - 1);
					const int pEnd = min(p, k + 2);
					const int n1 = nEnd - nStart;
					const int m1 = mEnd - mStart;
					const int p1 = pEnd - pStart;

					int* part = new int[n1 * m1 * p1]; /* size needs to be known at runtime */

					for (int iii = nStart; iii < nEnd; iii++)
					{
						for (int jjj = mStart; jjj < mEnd; jjj++)
						{
							for (int kkk = pStart; kkk < pEnd; kkk++)
							{
								part[(iii - nStart) + n1 * ((jjj - mStart) + m1 * (kkk - pStart))] = warping[iii + n * (jjj + m * kkk)];
							}
						}
					}

					int simple = testIsSimple(part, n1, m1, p1);

					/* Delete part */
					delete[] part;

					if (S[i + n * (j + m * k)] == 1)
					{
						if (1 - simple)
						{
							S[i + n * (j + m * k)] = 0;
						}

					}
					else
					{
						if ((simple) && (S[i + n * (j + m * k)] == 0))
						{
							S[i + n * (j + m * k)] = 1;
						}
					}
				}
			}
		}
	}

	/* Delete S */
	delete[] S;

	return;
}