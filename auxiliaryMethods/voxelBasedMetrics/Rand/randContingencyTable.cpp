// randContingencyTable.cpp : Defines the initialization routines for the DLL.
//

#include "stdafx.h"
#include "randContingencyTable.h"
#include "mex.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

//
//TODO: If this DLL is dynamically linked against the MFC DLLs,
//		any functions exported from this DLL which call into
//		MFC must have the AFX_MANAGE_STATE macro added at the
//		very beginning of the function.
//
//		For example:
//
//		extern "C" BOOL PASCAL EXPORT ExportedFunction()
//		{
//			AFX_MANAGE_STATE(AfxGetStaticModuleState());
//			// normal function body here
//		}
//
//		It is very important that this macro appear in each
//		function, prior to any calls into MFC.  This means that
//		it must appear as the first statement within the 
//		function, even before any object variable declarations
//		as their constructors may generate calls into the MFC
//		DLL.
//
//		Please see MFC Technical Notes 33 and 58 for additional
//		details.
//

// CrandContingencyTableApp

BEGIN_MESSAGE_MAP(CrandContingencyTableApp, CWinApp)
END_MESSAGE_MAP()


// CrandContingencyTableApp construction

CrandContingencyTableApp::CrandContingencyTableApp()
{
	// TODO: add construction code here,
	// Place all significant initialization in InitInstance
}


// The one and only CrandContingencyTableApp object

CrandContingencyTableApp theApp;


// CrandContingencyTableApp initialization

BOOL CrandContingencyTableApp::InitInstance()
{
	CWinApp::InitInstance();

	return TRUE;
}


//#include <math.h>

/* randContingencyTable.CPP Use to calculate the crucial stage of the full rand error as proposed 
by Hubert and Arabie (1985)
Syntax: cT = randContingencyTable( seg1, seg2, unique1, unique2 );
The input arguments seg1 and seg2 need to be three dimensional and integral
The input arguments unique1 and unique2 need to be integral and vectors containing the unique labels
of seg1 and seg2 respectively in an ordered fashion */

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	/* Macros for the ouput and input arguments */
	#define CT_OUT plhs[0]
	#define Seg1_IN prhs[0]
	#define Seg2_IN prhs[1]
	#define Unique1_IN prhs[2]
	#define Unique2_IN prhs[3]

	/* Initialize all variables */
	double *cT;
	int *seg1, *seg2, *unique1, *unique2, n, m, p, i, j, k, nUnique1, nUnique2;

	const mwSize *segDim = mxGetDimensions(Seg1_IN); /* Get the dimensions of Seg_IN */
	n = segDim[0];
	m = segDim[1];
	p = segDim[2];

	const mwSize *unique1Dim = mxGetDimensions(Unique1_IN); /* Get the dimensions of Unique1_IN */
	nUnique1 = max(unique1Dim[0], unique1Dim[1]);
	const mwSize *unique2Dim = mxGetDimensions(Unique2_IN); /* Get the dimensions of Unique2_IN */
	nUnique2 = max(unique2Dim[0], unique2Dim[1]);

	seg1 = (int *)mxGetData(Seg1_IN); /* Get the pointer to the data of seg1 */
	seg2 = (int *)mxGetData(Seg2_IN); /* Get the pointer to the data of seg2 */
	unique1 = (int *)mxGetData(Unique1_IN); /* Get the pointer to the data of unique1 */
	unique2 = (int *)mxGetData(Unique2_IN); /* Get the pointer to the data of unique2 */

	CT_OUT = mxCreateDoubleMatrix(nUnique1, nUnique2, mxREAL);; /* Create the output matrix */
	cT = mxGetPr(CT_OUT); /* Get the pointer to the data of Err_OUT */

	/* Create lookups for unique */
	int max1 = 0;
	int max2 = 0;

	for (i = 0; i < nUnique1; i++)
	{
		if (unique1[i] > max1)
			max1 = unique1[i];
	}

	for (i = 0; i < nUnique2; i++)
	{
		if (unique2[i] > max2)
			max2 = unique2[i];
	}

	int* lookup1 = new int[max1 + 1]; /* size needs to be known at runtime */
	int* lookup2 = new int[max2 + 1]; /* size needs to be known at runtime */

	for (i = 0; i < nUnique1; i++)
		lookup1[unique1[i]] = i;

	for (i = 0; i < nUnique2; i++)
		lookup2[unique2[i]] = i;
	
	/* Compute contigency table. cT[i,j] = #(objects ín class unique1[i] and unique2[j]) */
	for (i = 0; i < n; i++)
	{
		for (j = 0; j < m; j++)
		{
			for (k = 0; k < p; k++)
			{
				int thisSeg1 = seg1[i + n * (j + m * k)];
				int thisSeg2 = seg2[i + n * (j + m * k)];
				int thisLabel1 = lookup1[thisSeg1];
				int thisLabel2 = lookup2[thisSeg2];

				cT[thisLabel1 + nUnique1 * thisLabel2] += 1;
			} 
		}
	}      

	/* Delete dynamic arrays */
	delete[] lookup1;
	delete[] lookup2;

	return;
}