/* *************************************************************************************************** */
/* parseNML.c   NML parser for Knossos and Oxalis                                                      */
/* Copyright 2013 Max Planck Institute of Neurobiology, Martinsried                                    */
/* Version 0.11   Martin Zauser                                                                        */
/* *************************************************************************************************** */

/* 26.07.2013   V0.10   MAX_NUMBER_OF_COMMENTS increased from 2000 to 8000 because iris tracing is ~3000 */

/* parseNML XML-Parser */
#include "mex.h"
#include "stdio.h"
#include "time.h"

#define VERSION       "0.11"
#define VERSION_DATE  "19.09.2013"

/* without DEBUG_MODE for high speed parsing (for DEBUG_MODE just remove the double slash) */
/*#define DEBUG_MODE */

/* memory variables */
#define MEMORY_SIZE              40000000
#define MAX_NUMBER_OF_ELEMENTS     600000
#define MAX_NUMBER_OF_ATTRIBUTES    10000
#define MAX_NUMBER_OF_NODES        600000
#define MAX_NUMBER_OF_EDGES        600000
#define MAX_NUMBER_OF_BRANCHPOINTS   2000
#define MAX_NUMBER_OF_THINGS         2000
#define MAX_NUMBER_OF_PARAMETERS      500
#define MAX_NUMBER_OF_PARAMETER_ATTRIBUTES_TOTAL  10000
#define MAX_NUMBER_OF_COMMENTS       8000
unsigned char nmlMemory[MEMORY_SIZE];
unsigned char *pElementList[MAX_NUMBER_OF_ELEMENTS];
int iNumberOfAttributes[MAX_NUMBER_OF_ELEMENTS];
unsigned char *pAttributeName[MAX_NUMBER_OF_ATTRIBUTES];
unsigned char *pAttributeValue[MAX_NUMBER_OF_ATTRIBUTES];
long int gMemorypointer;
long int gMemorypointerCurrent;
long int nmlElementCounter;
long int nmlAttributeCounter;
long int nmlParameterCounter;
long int nmlThingCounter;
long int nmlCommentCounter;
int iNumberOfParameterAttributes[MAX_NUMBER_OF_PARAMETERS];
unsigned char *pParameterName[MAX_NUMBER_OF_PARAMETERS];
unsigned char *pParameterAttributeName[MAX_NUMBER_OF_PARAMETER_ATTRIBUTES_TOTAL];
unsigned char *pParameterAttributeValue[MAX_NUMBER_OF_PARAMETER_ATTRIBUTES_TOTAL];
long int gLineCounter;
#define NUM_OF_NODE_ATTRIBUTES_NML_FILE 8
double dNode[MAX_NUMBER_OF_NODES][NUM_OF_NODE_ATTRIBUTES_NML_FILE];
int iNodeThingNumber[MAX_NUMBER_OF_NODES];
int iNodeIdConversion[MAX_NUMBER_OF_NODES + 1]; /* +1 because it starts with 0 */
int iNodeIdConversionAllThings[MAX_NUMBER_OF_NODES + 1]; /* +1 because it starts with 0 */
unsigned char *pNode[MAX_NUMBER_OF_NODES][NUM_OF_NODE_ATTRIBUTES_NML_FILE];
unsigned char *pNodeComment[MAX_NUMBER_OF_NODES];
int iEdge[MAX_NUMBER_OF_EDGES][2];
int iBranchpoint[MAX_NUMBER_OF_BRANCHPOINTS];
double dThingID[MAX_NUMBER_OF_THINGS];
unsigned char *pThingName[MAX_NUMBER_OF_THINGS];
int iCommentNodeID[MAX_NUMBER_OF_COMMENTS];
unsigned char *pCommentContent[MAX_NUMBER_OF_COMMENTS];
int iNumberOfNodes;
int iNumberOfNodesThing[MAX_NUMBER_OF_THINGS];
int iNumberOfEdges;
int iNumberOfEdgesThing[MAX_NUMBER_OF_THINGS];
int iNumberOfBranchpoints;
/* input-output variables */
#define MESSAGE_BUFFER_SIZE   200
unsigned char szMessageBuffer[MESSAGE_BUFFER_SIZE];

/* element variables */
#define MAX_LENGTH_NMLELEMENT       100
#define MAX_LENGTH_ATTRIBUTE_NAME   100
#define MAX_LENGTH_ATTRIBUTE_VALUE  100
unsigned char szNmlElement[MAX_LENGTH_NMLELEMENT + 1 + 1];  /* +1 for ending slash and +1 for ending zero */
int statusElementClosed; /* 0 if open, 1 if closed with backslash */

/* prototypes */
void mexFunction (int nlhs , mxArray *plhs[], int nrhs , const mxArray *prhs[]);
int readCharacterFromFile (FILE* file);
int readNmlElement (FILE* file);
int readNmlString (FILE* file, unsigned char *szEndOfElement, unsigned char **pString);
int getIntegerAttribute (const char *szAttribute, int *iValue, int bShowErrorMessage);
int getDoubleAttribute (const char *szAttribute, double *dValue, unsigned char **pAttribute, int bShowErrorMessage);
int getStringAttribute (const char *szAttribute, unsigned char **pAttribute, int bShowErrorMessage);

/* DEBUG_MODE defines */
#ifdef DEBUG_MODE
    #define getCharacter readCharacterFromFile
#else
    #define getCharacter fgetc
#endif

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* ~~~~~~~~~~~~          CONSTANTS         ~~~~~~~~~~~~~~~~ */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* coding sections */
#define SECTION_MAIN                1
#define SECTION_READNMLSTRING       2
#define SECTION_READNMLELEMENT      3
#define SECTION_COMMENTSSTRING      4
#define SECTION_BRANCHPOINTSSTRING  5

/* error codes */
#define ERROR_OUT_OF_MEMORY         1

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* ~~~~~~~~~~~~          FUNCTIONS         ~~~~~~~~~~~~~~~~ */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */ 

/* error function */
void errorMessage (int iCodingSection, int iErrorType) {
    /* define text for coding section */
    switch (iCodingSection) {
        case SECTION_READNMLSTRING:
            sprintf(szMessageBuffer, "Braintracing:parseNML:readNmlString");
            break;
        case SECTION_READNMLELEMENT:
            sprintf(szMessageBuffer, "Braintracing:parseNML:readNmlElement");
            break;
        case SECTION_COMMENTSSTRING:
            sprintf(szMessageBuffer, "Braintracing:parseNML:commentsString");
            break;
        case SECTION_BRANCHPOINTSSTRING:
            sprintf(szMessageBuffer, "Braintracing:parseNML:branchpointsString");
            break;
        case SECTION_MAIN:
        default:
            sprintf(szMessageBuffer, "Braintracing:parseNML:mainFunction");
            break;
    }
    /* send error message */
    switch (iErrorType) {
        case ERROR_OUT_OF_MEMORY:
            if (iCodingSection == SECTION_COMMENTSSTRING) {
                mexErrMsgIdAndTxt(szMessageBuffer, "Out of memory. Cannot write comments. Please increase constant MEMORY_SIZE (line 19).");
            } else {
                mexErrMsgIdAndTxt(szMessageBuffer, "Out of memory. Please increase constant MEMORY_SIZE (line 19).");
            }
            break;
        default:
            mexErrMsgIdAndTxt(szMessageBuffer, "Unknown internal error.");
            break;
    }
    return;
}

/* read character from file (DEBUG_MODE) */
int readCharacterFromFile (FILE* file) {
    int character;
    character = fgetc (file);
    if (character == 0x0A) {
        gLineCounter++;
    }
    return character;
}

/* read attribute as integer value from memory (from last element) */
int getIntegerAttribute (const char *szAttribute, int *iValue, int bShowErrorMessage) {
    int i;
    int bFoundAttributeName;

    /* initialize value */
    *iValue = 0;

    /* initialize other variables */
    bFoundAttributeName = false;

    /* check number of elements */
    if (nmlElementCounter <= 0) {
        mexErrMsgIdAndTxt("Braintracing:parseNML:getIntegerAttribute", "No elements available.");
        return 1;
    }

    /* check number of attributes */
    if (iNumberOfAttributes[nmlElementCounter - 1] <= 0) {
        mexErrMsgIdAndTxt("Braintracing:parseNML:getIntegerAttribute", "No attributes available.");
        return 1;
    }

    /* search attribute name */
    for (i = 0; i < iNumberOfAttributes[nmlElementCounter - 1]; i++) {
        if (strcmp(pAttributeName[i], szAttribute) == 0) {
            /* convert attribute value to double */
            *iValue = atoi(pAttributeValue[i]);
            /* set "found" flag */
            bFoundAttributeName = true;
            break;
        }
    }

    /* attribute name not found */
    if (!bFoundAttributeName) {
        if (bShowErrorMessage) {
            /* show line number in debug mode */
            #ifdef DEBUG_MODE
                sprintf(szMessageBuffer, "Attribute %s not found in line %ld.", szAttribute, gLineCounter);
            #else
                sprintf(szMessageBuffer, "Attribute %s not found.", szAttribute);
            #endif
            mexErrMsgIdAndTxt("Braintracing:parseNML:getIntegerAttribute", szMessageBuffer);
        }
        return 1;
    }

    /* return OK */
    return 0;
}


/* read attribute as double value from memory (from last element) */
int getDoubleAttribute (const char *szAttribute, double *dValue, unsigned char **pAttribute, int bShowErrorMessage) {
    int i;
    int bFoundAttributeName;

    /* initialize value */
    *dValue = 0;
    *pAttribute = NULL;

    /* initialize other variables */
    bFoundAttributeName = false;
 
    /* check number of elements */
    if (nmlElementCounter <= 0) {
        mexErrMsgIdAndTxt("Braintracing:parseNML:getDoubleAttribute", "No elements available.");
        return 1;
    }

    /* check number of attributes */
    if (iNumberOfAttributes[nmlElementCounter - 1] <= 0) {
        mexErrMsgIdAndTxt("Braintracing:parseNML:getDoubleAttribute", "No attributes available.");
        return 1;
    }

    /* search attribute name */
    for (i = 0; i < iNumberOfAttributes[nmlElementCounter - 1]; i++) {
        if (strcmp(pAttributeName[i], szAttribute) == 0) {
            /* store pointer */
            *pAttribute = pAttributeValue[i];
            /* convert attribute value to double */
            *dValue = atof(pAttributeValue[i]);
            /* set "found" flag */
            bFoundAttributeName = true;
            break;
        }
    }

    /* attribute name not found */
    if (!bFoundAttributeName) {
        if (bShowErrorMessage) {
            /* show line number in debug mode */
            #ifdef DEBUG_MODE
                sprintf(szMessageBuffer, "Attribute %s not found in line %ld.", szAttribute, gLineCounter);
            #else
                sprintf(szMessageBuffer, "Attribute %s not found.", szAttribute);
            #endif
            mexErrMsgIdAndTxt("Braintracing:parseNML:getDoubleAttribute", szMessageBuffer);
        }
        return 1;
    }

    /* return OK */
    return 0;
}

/* read attribute as string value from memory (from last element) */
int getStringAttribute (const char *szAttribute, unsigned char **pAttribute, int bShowErrorMessage) {
    int i;
    int bFoundAttributeName;

    /* initialize value */
    *pAttribute = NULL;

    /* initialize other variables */
    bFoundAttributeName = false;

    /* check number of elements */
    if (nmlElementCounter <= 0) {
        mexErrMsgIdAndTxt("Braintracing:parseNML:getStringAttribute", "No elements available.");
        return 1;
    }

    /* check number of attributes */
    if (iNumberOfAttributes[nmlElementCounter - 1] <= 0) {
        mexErrMsgIdAndTxt("Braintracing:parseNML:getStringAttribute", "No attributes available.");
        return 1;
    }

    /* search attribute name */
    for (i = 0; i < iNumberOfAttributes[nmlElementCounter - 1]; i++) {
        if (strcmp(pAttributeName[i], szAttribute) == 0) {
            /* store pointer */
            *pAttribute = pAttributeValue[i];
            /* set "found" flag */
            bFoundAttributeName = true;
            break;
        }
    }

    /* attribute name not found */
    if (!bFoundAttributeName) {
        if (bShowErrorMessage) {
            /* show line number in debug mode */
            #ifdef DEBUG_MODE
                sprintf(szMessageBuffer, "Attribute %s not found in line %ld.", szAttribute, gLineCounter);
            #else
                sprintf(szMessageBuffer, "Attribute %s not found.", szAttribute);
            #endif
            mexErrMsgIdAndTxt("Braintracing:parseNML:getStringAttribute", szMessageBuffer);
        }
        /* return NOT OK */
        return 1;
    }

    /* return OK */
    return 0;
}

/* read single string until end and set pointer to string */
int readNmlString (FILE* file, unsigned char *szEndOfElement, unsigned char **pString) {
    unsigned char c;
    int iLengthEndOfString;
    int bRemoveSpaces;
    int bBeginning;
    long int gMemorypointerEnd;
    int i;
    /* store memory pointer */
    *pString = &nmlMemory[gMemorypointer];
    i = 0;
    gMemorypointerEnd = gMemorypointer;
    bRemoveSpaces = 1; /* 1 = section between > and <   0 = section between < and >  */
    bBeginning = 1;
    do {
        c = getCharacter (file);
        if (c == EOF) {
            mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlString", "Unexpected end of file in XML element.");
            return 1;
        }
        /* check for beginning */
        if (bBeginning) {
            if ((c == ' ') || (c == 0x09) || (c == 0x0D) || (c == 0x0A) || (c == 0x00)) {
                continue;
            }
            /* end of beginning ;-) */
            bBeginning = 0;
        }
        /* check for end */
        if ((i == 0) && (c == '>')) {
            gMemorypointerEnd = gMemorypointer;
        }
        /* check for "space mode" --> remove spaces and tabs between > and < */
        if (((c == ' ') || (c == 0x09)) && bRemoveSpaces) {
            continue;
        }
        if (bRemoveSpaces) {
            if (c == '<') {
                bRemoveSpaces = 0;
            }
        } else {
            if (c == '>') {
                bRemoveSpaces = 1;
            }
        }
        /* store character in memory */
        if (gMemorypointer >= MEMORY_SIZE) {
            errorMessage(SECTION_READNMLSTRING, ERROR_OUT_OF_MEMORY);
            return 1;
        }
        nmlMemory[gMemorypointer++] = c;
        /* check for < sign */
        if (i == 0) {
            if (c == '<') {
                i = 1;
                iLengthEndOfString = 1;
            }
            continue;
        }
        /* check for end of element */
        if ((i == 1) || (i == ((int)strlen(szEndOfElement) + 1))) {
            if (c == ' ') {
                iLengthEndOfString++;
                continue;
            }
            if ((i == ((int)strlen(szEndOfElement) + 1)) && (c == '>')) {
                /* found end of element */
                /* correct memory pointer */
                gMemorypointer -= (iLengthEndOfString + 1);
                /* remove whitespaces from the end */
                if ((gMemorypointerEnd + 1) <= gMemorypointer) {
                    while (((gMemorypointerEnd + 1) <= gMemorypointer) && ((nmlMemory[gMemorypointer - 1] == ' ') ||
                            (nmlMemory[gMemorypointer - 1] == 0x0D) || (nmlMemory[gMemorypointer - 1] == 0x0A) ||
                            (nmlMemory[gMemorypointer - 1] == 0x09) || (nmlMemory[gMemorypointer - 1] == 0x00))) {
                        gMemorypointer--;
                    }
                }
                /* store trailing zero in memory */
                nmlMemory[gMemorypointer++] = 0;
                /* return OK; */
                return 0;
            }
        }
        /* compare string */
        if (c == szEndOfElement[i - 1]) {
            i++;
            iLengthEndOfString++;
        } else {
            i = 0;
            iLengthEndOfString = 0;
        }
    } while (1);
    /* dummy return */
    return 1;
}


/* read single NML element (if an ending slash exists it will be added to the name of the element !!!  <name id="xx" value=0"/> --> "name/") */
int readNmlElement (FILE* file) {
    char c;
    int i;
    int iEndOfElement;
    char cTypeOfQuotationMark;
    /* delete previous element */
    szNmlElement[0] = 0;
    statusElementClosed = 0; /* 0 = open */

    /* read leading '<' */
    i = 0;
    do {
        c = getCharacter (file);
        if (c == EOF) {
            /* reached end of file --> return empty element */
            return 0;
        }
    } while (c != '<');

    /* read element name (i = number of characters) */
    do {
        /* read character */
        c = getCharacter (file);
        if (c == EOF) {
            mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlElement", "Unexpected end of file in XML element.");
            return 1;
        }

        /* check for special parameters beginning with ? and ignore it (for example: ?xml version="1.0") */
        /* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ?xml special >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
        if ((i == 0) && (c == '?')) {
            do {
                c = getCharacter (file);
                if (c == EOF) {
                    mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlElement", "Unexpected end of file in XML element.");
                    return 1;
                }
            } while (c != '>');
            /* read leading '<' again */
            do {
                c = getCharacter (file);
                if (c == EOF) {
                    /* reached end of file --> return empty element */
                    return 0; 
                }
            } while (c != '<');
            /* read first character of element name again */
            c = getCharacter (file);
            if (c == EOF) {
                mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlElement", "Unexpected end of file in XML element.");
                return 1;
            }
        }
        /* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ?xml special >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

        /* store character */
        if ((c != ' ') && (c != 0x00) && (c != 0x09) && (c != 0x0A) && (c != 0x0D) && (c != '>')) {
            /* +++++++++++++++++++++++++ */
            /* +++ element found !!! +++ */
            /* +++++++++++++++++++++++++ */
            /* store element pointer */
            if (i == 0) {
                if (nmlElementCounter >= MAX_NUMBER_OF_ELEMENTS) {
                    mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlElement", "Two many elements Please increase MAX_NUMBER_OF_ELEMENTS.");
                    return 1;
                }
                /* store element pointer */
                pElementList[nmlElementCounter] = &nmlMemory[gMemorypointer];
                /* reset number of attributes */
                iNumberOfAttributes[nmlElementCounter] = 0;
            } 
            /* store character */
            szNmlElement[i++] = c;
            /* store character in memory */
            if (gMemorypointer >= MEMORY_SIZE) {
                errorMessage(SECTION_READNMLELEMENT, ERROR_OUT_OF_MEMORY);
                return 1;
            }
            nmlMemory[gMemorypointer++] = c;
        }
        /* check length */
        if (i >= MAX_LENGTH_NMLELEMENT) {
            szNmlElement[MAX_LENGTH_NMLELEMENT] = 0;
            sprintf(szMessageBuffer, "NML element too long: %s... Maximal length is %d characters.\n", szNmlElement, MAX_LENGTH_NMLELEMENT);
            mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlElement", szMessageBuffer);
            return 1;
        }
    } while ((c != ' ') && (c != 0x00) && (c != 0x09) && (c != 0x0A) && (c != 0x0D) && (c != '>'));
    /* set trailing zero (name of element is now available in 'szNmlElement') */
    iEndOfElement = i;
    szNmlElement[i] = 0;
    /* store trailing zero in memory */
    if (gMemorypointer >= MEMORY_SIZE) {
        errorMessage(SECTION_READNMLELEMENT, ERROR_OUT_OF_MEMORY);
        return 1;
    }
    nmlMemory[gMemorypointer++] = 0;

    /* check element size (has to be at least 1 character) */
    if (i == 0) {
        mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlElement", "Empty NML element. Leading spaces not allowed in NML element.");
        return 1;
    }

    /* no attributes? fine, then return without attributes ;-) */
    if (c == '>') {
        /* store double trailing zero in memory */
        if (gMemorypointer >= MEMORY_SIZE) {
            errorMessage(SECTION_READNMLELEMENT, ERROR_OUT_OF_MEMORY);
            return 1;
        }
        nmlMemory[gMemorypointer++] = 0;
        /* increase element counter */
        nmlElementCounter++;
        /* return OK */
        return 0; 
    }

    /* loop: read all attribute names and values */
    do {
        /* read attribute name */
        i = 0;
        do {
            c = getCharacter (file);
            if (c == EOF) {
                mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlElement", "Unexpected end of file in XML element.");
                return 1;
            }
            /* ending slash --> add slash to name of element !!! */
            if ((c == '/') && (i == 0)) {
                szNmlElement[iEndOfElement] = c;
                szNmlElement[iEndOfElement + 1] = 0;
                statusElementClosed = 1;  /* 1 = closed */
                /* store slash in memory */
                if (gMemorypointer >= MEMORY_SIZE) {
                    errorMessage(SECTION_READNMLELEMENT, ERROR_OUT_OF_MEMORY);
                    return 1;
                }
                nmlMemory[gMemorypointer++] = c;
                /* read '>' */
                do {
                    c = getCharacter (file);
                    if (c == EOF) {
                        mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlElement", "Unexpected end of file in XML element.");
                        return 1;
                    }
                } while (c != '>');
                /* store double trailing zero in memory */
                if (gMemorypointer >= MEMORY_SIZE) {
                    errorMessage(SECTION_READNMLELEMENT, ERROR_OUT_OF_MEMORY);
                    return 1;
                }
                nmlMemory[gMemorypointer++] = 0;
                /* increase element counter */
                nmlElementCounter++;
                /* return OK */
                return 0;
            }
            /* end of element --> error, if there is an attribute without '=' */
            if (c == '>') {
                if (i == 0) {
                    /* store double trailing zero in memory */
                    if (gMemorypointer >= MEMORY_SIZE) {
                        errorMessage(SECTION_READNMLELEMENT, ERROR_OUT_OF_MEMORY);
                        return 1;
                    }
                    nmlMemory[gMemorypointer++] = 0;
                    /* increase element counter */
                    nmlElementCounter++;
                    /* return OK */
                    return 0;
                }
                mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlElement", "Unexpected end of file in XML element.");
                return 1;
            }
            /* store attribute name (ignore spaces in attribute name) */
            if ((c != ' ') && (c != 0x00) && (c != 0x09) && (c != 0x0A) && (c != 0x0D) && (c != '=')) {
                /* check forbidden characters */
                if ((c == '>') || (c == '/')) {
                    sprintf(szMessageBuffer, "Forbidden character in attribute name. May be attribute value is missing.\n");
                    mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlElement", szMessageBuffer);
                    return 1;
                }
                /* check max number of attributes */
                if (i == 0) {
                    if (nmlAttributeCounter >= MAX_NUMBER_OF_ATTRIBUTES) {
                        sprintf(szMessageBuffer, "Too many attributes in element %s.\n", szNmlElement);
                        mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlElement", szMessageBuffer);
                        return 1;
                    }
                    /* store pointer to attribute name */
                    pAttributeName[nmlAttributeCounter] = &nmlMemory[gMemorypointer];
                }
                i++;
                /* store character in memory */
                if (gMemorypointer >= MEMORY_SIZE) {
                    errorMessage(SECTION_READNMLELEMENT, ERROR_OUT_OF_MEMORY);
                    return 1;
                }
                nmlMemory[gMemorypointer++] = c;
            }
        } while (c != '=');
        /* store double zero in memory */
        if (gMemorypointer >= MEMORY_SIZE) {
            errorMessage(SECTION_READNMLELEMENT, ERROR_OUT_OF_MEMORY);
            return 1;
        }
        nmlMemory[gMemorypointer++] = 0;

        /* *********** QUOTATION MARK ********** */
        /* read quotation mark and ignore spaces */
        do {
            c = getCharacter (file);
            if (c == EOF) {
                mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlElement", "Unexpected end of file in XML element.");
                return 1;
            }
        } while ((c == ' ') || (c == 0x00) || (c == 0x09) || (c == 0x0A) || (c == 0x0D));
        /* check quotation mark " (hex22) or ' (hex27) */
        if ((c != 0x22) && (c != 0x27)) {
            mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlElement", "Argument value is missing. Quotation mark expected. Forgot it?");
            return 1;
        }
        /* remember type of quotation mark */
        cTypeOfQuotationMark = c;

        /* reset character counter */
        i = 0; 

        /* read attribute value */
        do {
            c = getCharacter (file);
            if (c == EOF) {
                mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlElement", "Unexpected end of file in XML element.");
                return 1;
            }
            /* store character */
            if (c != cTypeOfQuotationMark) {
                /* store pointer to attribute value */
                if (i == 0) {
                    pAttributeValue[nmlAttributeCounter] = &nmlMemory[gMemorypointer];
                }
                i++;
                /* store character in memory */
                if (gMemorypointer >= MEMORY_SIZE) {
                    errorMessage(SECTION_READNMLELEMENT, ERROR_OUT_OF_MEMORY);
                    return 1;
                }
                nmlMemory[gMemorypointer++] = c;
            }
        } while (c != cTypeOfQuotationMark);
        /* increase number of attributes per element and attribute counter */
        iNumberOfAttributes[nmlElementCounter]++;
        nmlAttributeCounter++;
        /* store double zero in memory */
        if (gMemorypointer >= MEMORY_SIZE) {
            errorMessage(SECTION_READNMLELEMENT, ERROR_OUT_OF_MEMORY);
            return 1;
        }
        nmlMemory[gMemorypointer++] = 0;

    } while (1);  /* endless loop --> reading attributes */

    /* dummy return value (to avoid warnings) */
    return 1;
}

void mexFunction (int nlhs , mxArray *plhs[], int nrhs , const mxArray *prhs[]) {

    /* declare variables */
    #define MAX_LENGTH_FILENAME  200
    #define MAX_LENGTH_PATH      200
    unsigned char szPathAndFilename[MAX_LENGTH_FILENAME + MAX_LENGTH_PATH + 1];
    unsigned char szFilename[MAX_LENGTH_FILENAME + 1];
    unsigned char szPath[MAX_LENGTH_PATH + 1];
    mxArray *mxGetFileOutput[2];
    mxArray *mxGetFileInput[2];
    const char *nmlStructFirstThing[] = { "parameters", "nodes", "nodesAsStruct", "nodesNumDataAll",
                                    "edges", "thingID", "name", "commentsString", "branchpointsString", "branchpoints"};
    const char *nmlStructLastThing[] = { "nodes", "nodesAsStruct", "nodesNumDataAll", "edges", "thingID", "name", "commentsString"};
    const char *nmlStructOtherThings[] = { "nodes", "nodesAsStruct", "nodesNumDataAll", "edges", "thingID", "name"};
    const char *nmlNodeAttributes[] = { "id", "radius", "x", "y", "z", "inVp", "inMag", "time", "comment" };
    const char *nmlEdgeAttributes[] = { "source", "target" };
    const char *nmlBranchpointAttributes[] = { "id" };
    int nmlNodeAttributeOrder[] = { 2, 3, 4, 1 };
    #define NUM_OF_NODE_ATTRIBUTES_ALL     (sizeof (nmlNodeAttributes) / sizeof (const char *))
    #define NUM_OF_NODE_ATTRIBUTES         (sizeof (nmlNodeAttributeOrder) / sizeof (int))
    #define NUM_OF_EDGE_ATTRIBUTES         (sizeof (nmlEdgeAttributes) / sizeof (const char *))
    #define NUM_OF_BRANCHPOINT_ATTRIBUTES  (sizeof (nmlBranchpointAttributes) / sizeof (const char *))
    /* general variables */
    int i, j, k;
    double d;
    unsigned char *p;
    time_t time_start;
    int iLength;
    int iNumberOfBytesWritten;
    int bCommentsAvailable;
    int iNumberOfNodesOffset;
    int iNumberOfEdgesOffset;
    int iDimensions[1];
    int iDimensionsNodes[2];
    int iKeepNodeAsStruct;
    int iNodeIDConverted;
    long int nmlElementCounterCurrent;

    /* xml variables */
    FILE* file;

    /* MATLAB variables */
    mwSize mwPointer;
    mxArray *nmlCell;
    mxArray *nmlCellCommentsString;
    mxArray *nmlCellLastCommentsString;
    mxArray *nmlCellBranchpointsString;
    mxArray *nmlStruct[MAX_NUMBER_OF_THINGS];
    mxArray *nmlParameterElementStruct;
    mxArray *nmlParameterAttributeStruct;
    mxArray *nmlCellNodeAsStruct[MAX_NUMBER_OF_THINGS];
    mxArray *nmlStructNodeAsStruct[MAX_NUMBER_OF_NODES];
    mxArray *nmlArrayNodesNumDataAll[MAX_NUMBER_OF_THINGS];
    double  *pArrayNodesNumDataAll;
    mxArray *nmlArrayNodes[MAX_NUMBER_OF_THINGS];
    double  *pArrayNodes;
    mxArray *nmlArrayEdges[MAX_NUMBER_OF_THINGS];
    double  *pArrayEdges;
    mxArray *nmlArrayBranchpoints;
    double  *pArrayBranchpoints;

    /* send welcome message */
    printf("This is Braintracing NML parser version %s, Copyright 2013 MPI of Neurobiology, Martinsried.\n", VERSION);
 
    /* check number of input arguments */
    if (nrhs > 2) {
        mexErrMsgIdAndTxt("Braintracing:parseNML:nrhs", "Only two parameters allowed: filename[character] and keepNodeAsStruct[0/1].");
        return;
    }
    if (nrhs < 1) {
        /* ************ */
        /* get filename */
        /* ************ */
        mxGetFileInput[0] = mxCreateString ("*.nml");
        mxGetFileInput[1] = mxCreateString ("Please select KNOSSOS or OXALIS .nml file");
        /* open file dialog */
        if (mexCallMATLAB(2, mxGetFileOutput, 2, mxGetFileInput, "uigetfile")) {
            mexErrMsgIdAndTxt("Braintracing:parseNML:FileDialog", "Filename missing. Could not select file.");
            return;
        }
        /* check for user abort */
        if ((mxIsClass(mxGetFileOutput[0], "double")) && (mxGetScalar(mxGetFileOutput[0]) == 0)) {
            mexErrMsgIdAndTxt("Braintracing:parseNML:FileDialog", "Filename missing. File dialog canceled by user.");
            return;
        }
        if (mxGetString(mxGetFileOutput[0], szFilename, MAX_LENGTH_FILENAME)) {
            mexErrMsgIdAndTxt("Braintracing:parseNML:FileDialog", "Filename invalid or too long.");
            return;
        }
        if (mxGetString(mxGetFileOutput[1], szPath, MAX_LENGTH_PATH)) {
            mexErrMsgIdAndTxt("Braintracing:parseNML:FileDialog", "Path invalid or too long.");
            return;
        }
        /* concatenate path and filename */
        sprintf(szPathAndFilename, "%s%s", szPath, szFilename);

    } else {
        /* check type of input argument */
        if( !mxIsClass(prhs[0], "char")) {
            mexErrMsgIdAndTxt("Braintracing:parseNML:notString", "Input parameter 'filename' must be a string.");
            return;
        }

        /* get file name */
        if (mxGetString(prhs[0], szPathAndFilename, MAX_LENGTH_FILENAME)) {
            mexErrMsgIdAndTxt("Braintracing:parseNML:FilenameTooLong", "Input parameter 'filename' too long.");
            return;
        }
    }

    /* intialize optional parameter */
    iKeepNodeAsStruct = 1;
    /* check second argument */
    if (nrhs == 2) {
        /* check type of secondinput argument */
        if( !mxIsClass(prhs[1], "double")) { 
            mexErrMsgIdAndTxt("Braintracing:parseNML:notString", "Input parameter 'keepNodeAsStruct' must be 0 or 1.");
            return;
        }
        /* get parameter */
        iKeepNodeAsStruct = (int)mxGetScalar(prhs[1]);
    }

    /* check number of output arguments */
    if (nlhs != 1) {
        mexErrMsgIdAndTxt("Braintracing:parseNML:nlhs", "Output required. Proper use of function is 'MyVar = parseNML FileName'");
        return;
    }

    /* start time */
    time_start = time(NULL);

    /* open file */
    if (!(file = fopen (szPathAndFilename, "r"))) {
        sprintf(szMessageBuffer, "Cannot open file %s.\n", szPathAndFilename);
        mexErrMsgIdAndTxt("Braintracing:parseNML:OpenFile", szMessageBuffer);
        return;
    }

    /* ************** */
    /* parse nml file */
    /* ***************/


    /* initialize global variables */
    iNumberOfNodes = 0;
    iNumberOfEdges = 0;
    iNumberOfBranchpoints = 0;
    gLineCounter = 0;

    /* initialize local variables */
    bCommentsAvailable = false;

    /* initialize dimensions */
    iDimensions[0] = 1;

    /* initialize node ID conversion and node thing id */
    for (i = 0; i < MAX_NUMBER_OF_NODES; i++) {
        iNodeIdConversion[i] = 0;
        pNodeComment[i] = NULL;
        iNodeThingNumber[i] = -1;
    }
 
    /* reset memory pointers and counters */
    gMemorypointer = 0;
    gMemorypointerCurrent = 0;
    nmlElementCounter = 0;
    nmlAttributeCounter = 0;
    nmlParameterCounter = 0;
    nmlThingCounter = 0;
    nmlCommentCounter = 0;

    /* things */
    readNmlElement(file);
    if (strcmp(szNmlElement, "things")) {
        sprintf(szMessageBuffer, "Expected element things. Got %s.\n", szNmlElement);
        mexErrMsgIdAndTxt("Braintracing:parseNML:things", szMessageBuffer);
        return;
    }

    /* reset memory pointer */
    gMemorypointer = gMemorypointerCurrent;

    /* oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo*/ 
    /* oooooooo    read all elements until end (= "/things")      ooooooooooooo */
    /* oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo*/
    do {
        /* reset counters*/
        nmlElementCounter = 0;
        nmlAttributeCounter = 0;

        /* save memory pointer (last position) */
        gMemorypointerCurrent = gMemorypointer;

        /* read element */
        readNmlElement(file);

        /* ignore empty elements */
        if ((strcmp(szNmlElement, "parameters/") == 0) || (strcmp(szNmlElement, "comments/") == 0) || (strcmp(szNmlElement, "branchpoints/") == 0) ||
            (strcmp(szNmlElement, "thing/") == 0)) {
            /* reset memory pointer */
            gMemorypointer = gMemorypointerCurrent;
            continue;
        }
        
        /* read comments */
        if (strcmp(szNmlElement, "comments") == 0) {
            /* reset element and attribute counters */
            nmlElementCounter = 0;
            nmlAttributeCounter = 0;

            bCommentsAvailable = true;

            /* reset memory pointer */
            gMemorypointer = gMemorypointerCurrent;

            do {
                /* reset attribute counter */
                nmlAttributeCounter = 0;
                /* save memory pointer (last position) */
                gMemorypointerCurrent = gMemorypointer;

                /* read element */
                if (readNmlElement(file)) {
                    /* stop program after error */
                    fclose (file);
                    plhs[0] = mxCreateCellMatrix (1, 1);
                    return;
                }

                /* ignore end of comment elements) */
                if (strcmp(szNmlElement, "/comment") == 0) {
                    /* reset memory pointer */
                    gMemorypointer = gMemorypointerCurrent;
                    continue;
                }

                /* check element */
                if ((strcmp(szNmlElement, "comment") != 0) && (strcmp(szNmlElement, "comment/") != 0)  && (strcmp(szNmlElement, "/comments") != 0)) {
                    sprintf(szMessageBuffer, "Illegal element %s in comment line %ld.", szNmlElement, (nmlCommentCounter + 1));
                    mexErrMsgIdAndTxt("Braintracing:parseNML:comment", szMessageBuffer);
                    return;
                }

                if ((strcmp(szNmlElement, "comment") == 0) || (strcmp(szNmlElement, "comment/") == 0)) {
                    /* check node counter */
                    if (nmlCommentCounter >= MAX_NUMBER_OF_COMMENTS) {
                        mexErrMsgIdAndTxt("Braintracing:parseNML:comment", "Too many comments in nml file. Increasing MAX_NUMBER_OF_COMMENTS could help.");
                        return;
                    }

                    /* get comment attributes (id and content) */
                    if (getIntegerAttribute ("node", &i, true)) {
                        /* stop program after error */
                        fclose (file);
                        plhs[0] = mxCreateCellMatrix (1, 1);
                        return;
                    }
                    /* check node id value */
                    if ((i <= 0) || (i > MAX_NUMBER_OF_NODES)) {
                        sprintf(szMessageBuffer, "Illegal node id %d in comment line %ld. Must be >= 1 and <= %d.\n",
                                i, (nmlCommentCounter + 1), MAX_NUMBER_OF_NODES);
                        mexErrMsgIdAndTxt("Braintracing:parseNML:comment", szMessageBuffer);
                        return;
                    }
                    /* store integer value of id in memory */
                    iCommentNodeID[nmlCommentCounter] = i;

                    /* get comment content */
                    if (getStringAttribute ("content", &p, true)) {
                        /* stop program after error */
                        fclose (file);
                        plhs[0] = mxCreateCellMatrix (1, 1);
                        return;
                    }
                    /* store comment in memory */
                    pCommentContent[nmlCommentCounter] = p;
                    pNodeComment[iNodeIdConversionAllThings[i]] = p;

                    /* increase comment counter */
                    nmlCommentCounter++;
                }

            } while (strcmp(szNmlElement, "/comments"));

            /* reset memory pointer */
            gMemorypointer = gMemorypointerCurrent;

            continue;
        }

        /* read parameters */
        if (strcmp(szNmlElement, "parameters") == 0) {
            /* decrease element counter by 1 (because "parameters" is supposed to have no attributes and therefore the element itself is not needed) */
            nmlElementCounter--;
            /* save element counter */
            nmlElementCounterCurrent = nmlElementCounter;
            /* read parameters */
            nmlParameterCounter = 0;
            if (!statusElementClosed) {
                do {
                    readNmlElement(file);
                    if ((szNmlElement[0] != '/') && (strcmp(szNmlElement, "/parameters"))) {
                        if (nmlParameterCounter >= MAX_NUMBER_OF_PARAMETERS) {
                            mexErrMsgIdAndTxt("Braintracing:parseNML:parameters", "Too many parameters in nml file. "
                                              "Increasing MAX_NUMBER_OF_PARAMETERS could help.");
                            return;
                        }
                        if (nmlElementCounter <= 0) {
                            mexErrMsgIdAndTxt("Braintracing:parseNML:parameters", "Internal error. No parameter section found.");
                            return;
                        }
                        pParameterName[nmlParameterCounter] = pElementList[nmlElementCounter - 1];
                        nmlParameterCounter++;
                    } else {
                        /* decrease element counter by 1 (because /parameters is no element) */
                        nmlElementCounter--;
                    }
                } while ((szNmlElement[0] != '/') && (strcmp(szNmlElement, "/parameters"))); /* two comparisons fastens loop */
            }
            /* read parameters into struct */
            nmlAttributeCounter = 0;
            for (i = 0; i < nmlParameterCounter; i++) {
                iNumberOfParameterAttributes[i] = iNumberOfAttributes[nmlElementCounterCurrent + i];
                for (j = 0; j < iNumberOfAttributes[nmlElementCounterCurrent + i]; j++) {
                    if (nmlAttributeCounter >= MAX_NUMBER_OF_PARAMETER_ATTRIBUTES_TOTAL) {
                        mexErrMsgIdAndTxt("Braintracing:parseNML:parameters", "Too many parameter attributes in nml file. "
                                          "Increasing MAX_NUMBER_OF_PARAMETER_ATTRIBUTES_TOTAL could help.");
                        return;
                    }
                    pParameterAttributeName[nmlAttributeCounter] = pAttributeName[nmlAttributeCounter];
                    pParameterAttributeValue[nmlAttributeCounter] = pAttributeValue[nmlAttributeCounter];
                    nmlAttributeCounter++;
                }
            }
            /* DO NOT RESET MEMORY POINTER HERE !!!  DATA WILL BE USED LATER !!!  (FORBIDDEN:  gMemorypointer = gMemorypointerCurrent;) */
            continue;
        }

        /* *************************** */
        /* ****   thing (=tree)   **** */
        /* *************************** */
        if (strcmp(szNmlElement, "thing") == 0) { 

            /* get thing id */
            if (getDoubleAttribute("id", &d, &p, true)) {
                /* stop program after error */
                fclose (file);
                plhs[0] = mxCreateCellMatrix (1, 1);
                return;
            }
            /* store thing id */
            if (nmlThingCounter >= MAX_NUMBER_OF_THINGS) {
                mexErrMsgIdAndTxt("Braintracing:parseNML:thing", "Too many things in nml file. Increasing MAX_NUMBER_OF_THINGS could help.");
                return;
            }
            dThingID[nmlThingCounter] = d;

            /* get thing name */
            if (getStringAttribute("name", &p, false)) {
                pThingName[nmlThingCounter] = NULL;
                /* no error message because older .nml files don't support thing names */
            }
            pThingName[nmlThingCounter] = p;

            /* reset number of nodes and edges */
            iNumberOfNodesThing[nmlThingCounter] = 0;
            iNumberOfEdgesThing[nmlThingCounter] = 0;

            /* reset element and attribute counters */
            nmlElementCounter = 0;
            nmlAttributeCounter = 0;

            do {
                /* reset attribute counter */
                nmlAttributeCounter = 0;
                /* save memory pointer (last position) */
                gMemorypointerCurrent = gMemorypointer;

                /* read element */
                if (readNmlElement(file)) {
                    /* stop program after error */
                    fclose (file);
                    plhs[0] = mxCreateCellMatrix (1, 1);
                    return;
                }

                /* ignore empty elements <nodes/> and <edges/> (there should be no empty elements anyway) */
                if ((strcmp(szNmlElement, "nodes/") == 0) || (strcmp(szNmlElement, "edges/") == 0)) {
                    /* reset memory pointer */
                    gMemorypointer = gMemorypointerCurrent;
                    continue;
                }

                /* ignore element nodes and edges (just for comfort; strictly speaking you had to check that nodes contains only node and edges only edge) */
                if ((strcmp(szNmlElement, "nodes") == 0) || (strcmp(szNmlElement, "/nodes") == 0) ||
                    (strcmp(szNmlElement, "edges") == 0) || (strcmp(szNmlElement, "/edges") == 0)) {
                    /* reset memory pointer */
                    gMemorypointer = gMemorypointerCurrent;
                    continue;
                }

                /* ignore closing elements </nodes> and </edges> */
                if ((strcmp(szNmlElement, "/nodes") == 0) || (strcmp(szNmlElement, "/edges") == 0)) {
                    /* reset memory pointer */
                    gMemorypointer = gMemorypointerCurrent;
                    continue;
                }

                /* +++++++++++++++++++++ */
                /* ++++  read node  ++++ */
                /* +++++++++++++++++++++ */
                if ((strcmp(szNmlElement, "node") == 0) || (strcmp(szNmlElement, "node/") == 0)) {
                    /* check node counter */
                    if (iNumberOfNodes >= MAX_NUMBER_OF_NODES) {
                        mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlElement", "Too many nodes in nml file. Increasing MAX_NUMBER_OF_NODES could help.\n");
                        return;
                    }

                    /* get node attributes */
                    for (i = 0; i < NUM_OF_NODE_ATTRIBUTES_ALL; i++) {
                        /* comment attribute not available */
                        if (strcmp(nmlNodeAttributes[i], "comment") == 0) {
                            continue;
                        }
                        /* check size */
                        if (i >= NUM_OF_NODE_ATTRIBUTES_NML_FILE) {
                            continue;
                        }
                        /* get attribute */
                        if (getDoubleAttribute (nmlNodeAttributes[i], &d, &p, true)) {
                            /* stop program after error */
                            fclose (file);
                            plhs[0] = mxCreateCellMatrix (1, 1);
                            return;
                        }
                        /* store double value and pointer of attribute in memory */
                        dNode[iNumberOfNodes][i] = d;
                        pNode[iNumberOfNodes][i] = p;
                        /* calculate node ID conversion (id = attribute index 0) */
                        if (i == 0) {
                            if (dNode[iNumberOfNodes][0] >= MAX_NUMBER_OF_NODES) {
                                sprintf(szMessageBuffer, "Node ID %d too big. Increasing MAX_NUMBER_OF_NODES could help.",
                                        (int)dNode[iNumberOfNodes][0]);
                                mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlElement", szMessageBuffer);
                                return;
                            }
                            iNodeIdConversionAllThings[(int)d] = iNumberOfNodes;
                        }
                    }

                    /* store thing number */
                    iNodeThingNumber[(int)dNode[iNumberOfNodes][0]] = nmlThingCounter;

                    /* increase node counter */
                    iNumberOfNodes++;
                    iNumberOfNodesThing[nmlThingCounter]++;

                    /* DO NOT RESET MEMORY POINTER HERE !!!  DATA WILL BE USED LATER !!!  (FORBIDDEN:  gMemorypointer = gMemorypointerCurrent;) */
                    continue;
                }

                /* +++++++++++++++++++++ */
                /* ++++  read edge  ++++ */
                /* +++++++++++++++++++++ */
                if ((strcmp(szNmlElement, "edge") == 0) || (strcmp(szNmlElement, "edge/") == 0)) {
                    /* check edge counter */
                    if (iNumberOfEdges >= MAX_NUMBER_OF_EDGES) {
                        mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlElement", "Too many edges in nml file. Increasing MAX_NUMBER_OF_EDGES could help.\n");
                        return;
                    }

                    /* get edge attributes (source and target) */
                    for (i = 0; i < NUM_OF_EDGE_ATTRIBUTES; i++) {
                        /* get attribute */
                        if (getIntegerAttribute (nmlEdgeAttributes[i], &j, true)) {
                            /* stop program after error */
                            fclose (file);
                            plhs[0] = mxCreateCellMatrix (1, 1);
                            return;
                        }
                        /* check edge value */
                        if ((j <= 0) || (j > MAX_NUMBER_OF_NODES)) {
                            sprintf(szMessageBuffer, "Illegal edge source or target %d in edge line %d. Must be >= 1 and <= %d.\n",
                                    j, (iNumberOfEdges + 1), MAX_NUMBER_OF_NODES);
                            mexErrMsgIdAndTxt("Braintracing:parseNML:edge", szMessageBuffer);
                            return;
                        }
                        /* store integer value of attribute in memory */
                        iEdge[iNumberOfEdges][i] = j;
                    }

                    /* increase edge counter */
                    iNumberOfEdges++;
                    iNumberOfEdgesThing[nmlThingCounter]++;

                    /* reset memory pointer (for saving memory space) because no further "edge" data except source and target is needed */
                    gMemorypointer = gMemorypointerCurrent;
                    continue;
                }

            } while (strcmp(szNmlElement, "/thing"));

            /* increase thing counter */
            nmlThingCounter++;

        }

        /* *********************************** */
        /* ****      branchpoints         **** */
        /* *********************************** */
        if (strcmp(szNmlElement, "branchpoints") == 0) {
            /* read branchpoints */
            do {
                /* reset attribute counter */
                nmlAttributeCounter = 0;
                /* save memory pointer (last position) */
                gMemorypointerCurrent = gMemorypointer;

                /* read element */
                if (readNmlElement(file)) {
                    /* stop program after error */
                    fclose (file);
                    plhs[0] = mxCreateCellMatrix (1, 1);
                    return;
                }

                /* ++++++++++++++++++++++++++++ */
                /* ++++  read branchpoint  ++++ */
                /* ++++++++++++++++++++++++++++ */
                if ((strcmp(szNmlElement, "branchpoint") == 0) || (strcmp(szNmlElement, "branchpoint/") == 0)) {
                    /* check branchpoint counter */
                    if (iNumberOfBranchpoints >= MAX_NUMBER_OF_BRANCHPOINTS) {
                        fclose (file);
                        mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlElement", "Too many branchpoints in nml file. "
                                          "Increasing MAX_NUMBER_OF_BRANCHPOINTS could help.");
                        plhs[0] = mxCreateCellMatrix (1, 1);
                        return;
                    }

                    /* get branchpoint attribute (id) */
                    if (getIntegerAttribute (nmlBranchpointAttributes[0], &j, true)) {
                        /* stop program after error */
                        fclose (file);
                        plhs[0] = mxCreateCellMatrix (1, 1);
                        return;
                    }
                    /* check branchpoint value */
                    if ((j <= 0) || (j > MAX_NUMBER_OF_NODES)) {
                        fclose (file);
                        sprintf(szMessageBuffer, "Illegal branchpoint id %d in branchpoint line %d. Must be >= 1 and <= %d.",
                                j, (iNumberOfBranchpoints + 1), MAX_NUMBER_OF_NODES);
                        mexErrMsgIdAndTxt("Braintracing:parseNML:branchpoint", szMessageBuffer);
                        plhs[0] = mxCreateCellMatrix (1, 1);
                        return;
                    }
                    /* store integer value of attribute in memory */
                    iBranchpoint[iNumberOfBranchpoints] = j;

                    /* increase branchpoint counter */
                    iNumberOfBranchpoints++;

                    /* reset memory pointer */
                    gMemorypointer = gMemorypointerCurrent;
                    continue;
                }
            } while (strcmp(szNmlElement, "/branchpoints"));
        }

    } while (strcmp(szNmlElement, "/things"));

    /* close file */
    fclose (file);

    /* ###################################################################### */
    /* #########              CREATE MATLAB CELL            ################# */
    /* ###################################################################### */
    /* check number of things */
    if (nmlThingCounter == 0) {
        mexErrMsgIdAndTxt("Braintracing:parseNML:things", "No things found.");
        return;
    }

    /* set cell and create keys for parameters, commentString usw. */
    /* first thing with parameters, commentString, branchpointsString and branchpoints */
    nmlCell = mxCreateCellMatrix (1, nmlThingCounter);
    nmlStruct[0] = mxCreateStructMatrix (1, 1, sizeof(nmlStructFirstThing) / sizeof(nmlStructFirstThing[0]), nmlStructFirstThing);
    mxSetCell (nmlCell, 0, nmlStruct[0]);
    /* other things only with nodes, nodesAsStruct, nodesNumDataAll, edges and thingID */
    if (nmlThingCounter > 1) {
        for (k = 1; k < (nmlThingCounter - 1); k++) {
            nmlStruct[k] = mxCreateStructMatrix (1, 1, sizeof(nmlStructOtherThings) / sizeof(nmlStructOtherThings[0]), nmlStructOtherThings);
            mxSetCell (nmlCell, k, nmlStruct[k]);
        }
        /* last thing with commentsString (due to writeKnossosNml.m) */
        k = nmlThingCounter - 1;
        nmlStruct[k] = mxCreateStructMatrix (1, 1, sizeof(nmlStructLastThing) / sizeof(nmlStructLastThing[0]), nmlStructLastThing);
        mxSetCell (nmlCell, k, nmlStruct[k]);
    }

    /* --> PARAMETERS <-- */
    /* store parameters in matlab array */
    if (nmlParameterCounter > 0) {
        nmlParameterElementStruct = mxCreateStructMatrix (1, 1, nmlParameterCounter, (const char **)pParameterName);
        nmlAttributeCounter = 0;
        for (i = 0; i < nmlParameterCounter; i++) {
            nmlParameterAttributeStruct = mxCreateStructMatrix (1, 1, iNumberOfParameterAttributes[i], (const char **)&pParameterAttributeName[nmlAttributeCounter]);
            for (j = 0; j < iNumberOfParameterAttributes[i]; j++) {
                mxSetFieldByNumber (nmlParameterAttributeStruct, 0, j, mxCreateString (pParameterAttributeValue[nmlAttributeCounter]));
                nmlAttributeCounter++;
            }
            mxSetFieldByNumber (nmlParameterElementStruct, 0, i, nmlParameterAttributeStruct);
        }
        mxSetField (nmlStruct[0], 0, "parameters", nmlParameterElementStruct);
    }

    /* --> THINGS <-- */
    iNumberOfNodesOffset = 0;
    iNumberOfEdgesOffset = 0;
    for (k = 0; k < nmlThingCounter; k++) {
        /* store thing id */
        mxSetField (nmlStruct[k], 0, "thingID", mxCreateDoubleScalar (dThingID[k]));
        /* initialize node id conversion */
        for (i = 0; i < MAX_NUMBER_OF_NODES; i++) {
            iNodeIdConversion[i] = 0;
        }

        /* store thing name */
        if (pThingName[k]) {
            mxSetField (nmlStruct[k], 0, "name", mxCreateString (pThingName[k]));
        }

        /* --> NODES <-- */
        /* store nodes in matlab array: Nodes and NodesNumDataAll */
        if (iNumberOfNodesThing[k] > 0) {
            /* calculate node id conversion */
            for (i = 0; i < iNumberOfNodesThing[k]; i++) {
                /* convert node id */
                iNodeIdConversion[(int)dNode[iNumberOfNodesOffset + i][0]] = i + 1;
            }

            /* ---------------------------------------------------------------- */
            /* Nodes */
            nmlArrayNodes[k] = mxCreateDoubleMatrix (iNumberOfNodesThing[k], NUM_OF_NODE_ATTRIBUTES, mxREAL);
            pArrayNodes = mxGetPr(nmlArrayNodes[k]);
            mwPointer = 0;
            for (j = 0; j < NUM_OF_NODE_ATTRIBUTES; j++) {
                for (i = 0; i < iNumberOfNodesThing[k]; i++) {
                    *(pArrayNodes + mwPointer) = dNode[iNumberOfNodesOffset + i][nmlNodeAttributeOrder[j]];
                    mwPointer++;
                }
            }
            /* set Nodes */
            mxSetField (nmlStruct[k], 0, "nodes", nmlArrayNodes[k]);
            /* ---------------------------------------------------------------- */
            /* NodesNumDataAll */
            nmlArrayNodesNumDataAll[k] = mxCreateDoubleMatrix (iNumberOfNodesThing[k], NUM_OF_NODE_ATTRIBUTES_ALL, mxREAL);
            pArrayNodesNumDataAll = mxGetPr(nmlArrayNodesNumDataAll[k]);
            mwPointer = 0;
            for (j = 0; j < NUM_OF_NODE_ATTRIBUTES_ALL; j++) {
                for (i = 0; i < iNumberOfNodesThing[k]; i++) {
                    *(pArrayNodesNumDataAll + mwPointer) = dNode[iNumberOfNodesOffset + i][j];
                    mwPointer++;
                }
            }
            /* set NodesNumDataAll */
            mxSetField (nmlStruct[k], 0, "nodesNumDataAll", nmlArrayNodesNumDataAll[k]);
            /* ---------------------------------------------------------------- */
            /* NodesAsStruct */
            if (iKeepNodeAsStruct) {
                iDimensionsNodes[0] = 1;
                iDimensionsNodes[1] = iNumberOfNodesThing[k];
                nmlCellNodeAsStruct[k] = mxCreateCellArray (2, iDimensionsNodes);
                for (i = 0; i < iNumberOfNodesThing[k]; i++) {
                    nmlStructNodeAsStruct[iNumberOfNodesOffset + i] = mxCreateStructMatrix (1, 1, NUM_OF_NODE_ATTRIBUTES_ALL, nmlNodeAttributes);
                    mxSetCell (nmlCellNodeAsStruct[k], i, nmlStructNodeAsStruct[iNumberOfNodesOffset + i]);
                    for (j = 0; j < NUM_OF_NODE_ATTRIBUTES_ALL; j++) {
                        if (strcmp(nmlNodeAttributes[j], "comment") == 0) {
                            p = pNodeComment[iNumberOfNodesOffset + i];
                        } else {
                            p = pNode[iNumberOfNodesOffset + i][j];
                        }
                        mxSetFieldByNumber (nmlStructNodeAsStruct[iNumberOfNodesOffset + i], 0, j, mxCreateString (p));
                    }
                }
                /* set nodesAsStruct */
                mxSetField (nmlStruct[k], 0, "nodesAsStruct", nmlCellNodeAsStruct[k]);
            }
            /* calculate nodes offset */
            iNumberOfNodesOffset += iNumberOfNodesThing[k];
        }

        /* --> EDGES <-- */
        /* store edges in matlab array */
        if (iNumberOfEdgesThing[k] > 0) {
            /* ---------------------------------------------------------------- */
            /* Edges */
            nmlArrayEdges[k] = mxCreateDoubleMatrix (iNumberOfEdgesThing[k], NUM_OF_EDGE_ATTRIBUTES, mxREAL);
            pArrayEdges = mxGetPr(nmlArrayEdges[k]);
            mwPointer = 0;
            for (j = 0; j < NUM_OF_EDGE_ATTRIBUTES; j++) {
                for (i = 0; i < iNumberOfEdgesThing[k]; i++) {
                    /* calculate node ids */
                    iNodeIDConverted = iNodeIdConversion[iEdge[iNumberOfEdgesOffset + i][j]];
                    /* check node converted id and warn if node id is not available */
                    if (iNodeIDConverted == 0)
                        printf("WARNING: Node ID %d is missing. Created incomplete edge pointing to 0.\n", iEdge[iNumberOfEdgesOffset + i][j]);
                    *(pArrayEdges + mwPointer) = (double)iNodeIDConverted;
                    mwPointer++;
                }
            }
            /* set edges */
            mxSetField (nmlStruct[k], 0, "edges", nmlArrayEdges[k]);
            /* ---------------------------------------------------------------- */
            /* calculate edges offset */
            iNumberOfEdgesOffset += iNumberOfEdgesThing[k];
        }
    }

    /* --> COMMENTS <-- */
    if (bCommentsAvailable) { /* do not intialize comments string if comments are not available
        /* create comments string for all things */
        /* save memory pointer (last position) */
        gMemorypointerCurrent = gMemorypointer;
        /* .................................................................... */
        /* add 16 characters initialisation (is necessary for writeKnossosNml.m) */
        iLength = 16;
        /* check free memory size */
        if (iLength >= (MEMORY_SIZE - gMemorypointer - 1)) {
            fclose (file);
            errorMessage(SECTION_COMMENTSSTRING, ERROR_OUT_OF_MEMORY);
            plhs[0] = mxCreateCellMatrix (1, 1);
            return;
        }
        /* write 16 characters */
        iNumberOfBytesWritten = sprintf(&nmlMemory[gMemorypointer], "<comments>     \x0A"); /* exactly 16 characters long */
        /* check success */
        if ((iNumberOfBytesWritten < 0) || (iNumberOfBytesWritten >= (MEMORY_SIZE - gMemorypointer - 1))) {
            fclose (file);
            errorMessage(SECTION_COMMENTSSTRING, ERROR_OUT_OF_MEMORY);
            plhs[0] = mxCreateCellMatrix (1, 1);
            return;
        }
        /* adjust memory pointer */
        gMemorypointer += iNumberOfBytesWritten;
        /* .................................................................... */
        /* ------------ */
        /* add comments */
        /* ------------ */
        for (i = 0; i < nmlCommentCounter; i++) {
            /* clear memory */
            nmlMemory[gMemorypointer] = 0;
/* TODO: This is a problem that should solved someday to avoid memory crash using huge files */
/* the snprintf function was not available in the compiler ;-( */
/*            iNumberOfBytesWritten = snprintf(&nmlMemory[gMemorypointer], MEMORY_SIZE - gMemorypointer - 1, */
/*                "%s<comment node=\"%d\" content=\"%s\"/>", (i > 0) ? "\n" : "", iCommentNodeID[i], pCommentContent[i]); */
/* the following solution checks memory size AFTER using it which could raise a memory violation exception in case memory isn't big enough */
            iNumberOfBytesWritten = sprintf(&nmlMemory[gMemorypointer],
                "%s<comment node=\"%d\" content=\"%s\"/>", (i > 0) ? "\n" : "", iCommentNodeID[i], pCommentContent[i]);
            if ((iNumberOfBytesWritten < 0) || (iNumberOfBytesWritten >= (MEMORY_SIZE - gMemorypointer - 1))) {
                fclose (file);
                errorMessage(SECTION_COMMENTSSTRING, ERROR_OUT_OF_MEMORY);
                plhs[0] = mxCreateCellMatrix (1, 1);
                return;
            }
            gMemorypointer += iNumberOfBytesWritten;
        }
        /* ....................................................................... */
        /* add 16 characters de-initialisation (is necessary for writeKnossosNml.m) */
        iLength = 16;
        /* check free memory size */
        if (iLength >= (MEMORY_SIZE - gMemorypointer - 1)) {
            fclose (file);
            errorMessage(SECTION_COMMENTSSTRING, ERROR_OUT_OF_MEMORY);
            plhs[0] = mxCreateCellMatrix (1, 1);
            return;
        }
        /* write 16 characters */
        iNumberOfBytesWritten = sprintf(&nmlMemory[gMemorypointer], "\x0A</comments>    "); /* exactly 16 characters long
        /* check success */
        if ((iNumberOfBytesWritten < 0) || (iNumberOfBytesWritten >= (MEMORY_SIZE - gMemorypointer - 1))) {
            fclose (file);
            errorMessage(SECTION_COMMENTSSTRING, ERROR_OUT_OF_MEMORY);
            plhs[0] = mxCreateCellMatrix (1, 1);
            return;
        }
        /* adjust memory pointer */
        gMemorypointer += iNumberOfBytesWritten; 
        /* ....................................................................... */
        /* write comments string if available */
        nmlCellCommentsString = mxCreateCellArray (1, iDimensions);
        mxSetCell (nmlCellCommentsString, 0, mxCreateString (&nmlMemory[gMemorypointerCurrent]));
        mxSetField (nmlStruct[0], 0, "commentsString", nmlCellCommentsString);
        /* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
        /* funny extension due to writeKnossosNml.m */
        /* if there are more than one things the LAST thing has to have a commentsString cell (don't ask me why) that can be empty */
        /* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
        if (nmlThingCounter > 1) {
            nmlCellLastCommentsString = mxCreateCellMatrix (0, 0);
            mxSetField (nmlStruct[nmlThingCounter - 1], 0, "commentsString", nmlCellLastCommentsString);
        }
    }

    /* --> BRANCHPOINTS <-- */
    /* store branchpoints in matlab array */
    /* ------------- ATTENTION !!! --------------------------------------------------------------------------------------------------- */
    /* ----- branchpoints MUST be processed as LAST struct because they use global memory (and overwrite existing data) ! */
    /* ------------------------------------------------------------------------------------------------------------------------------- */
    if (iNumberOfBranchpoints > 0) {
        /* ---------------------------------------------------------------- */
        /* list branchpoints */
        mwPointer = 0;
        nmlArrayBranchpoints = mxCreateDoubleMatrix (iNumberOfBranchpoints, NUM_OF_BRANCHPOINT_ATTRIBUTES, mxREAL);
        pArrayBranchpoints = mxGetPr(nmlArrayBranchpoints);
        for (i = 0; i < iNumberOfBranchpoints; i++) {
            *(pArrayBranchpoints + mwPointer) = (double)iBranchpoint[i];
            mwPointer++;
        }
        /* reset memory */
        gMemorypointer = 0;
        nmlMemory[gMemorypointer] = 0;
        for (i = 0; i < iNumberOfBranchpoints; i++) {
            /* create string */
            sprintf(szMessageBuffer, "<branchpoint id=\"%d\"/>%s", iBranchpoint[i], (i < (iNumberOfBranchpoints - 1)) ? "\n" : "");
            if ((long int)strlen(szMessageBuffer) + gMemorypointer + 1 >= MEMORY_SIZE) {
                errorMessage(SECTION_BRANCHPOINTSSTRING, ERROR_OUT_OF_MEMORY);
                plhs[0] = nmlCell;
                return;
            }
            for (j = 0; j < (int)strlen(szMessageBuffer); j++) {
                nmlMemory[gMemorypointer++] = szMessageBuffer[j];
            }
            /* add end mark of string (zero) */
            nmlMemory[gMemorypointer] = 0;
        }
        /* set branchpoints */
        mxSetField (nmlStruct[0], 0, "branchpoints", nmlArrayBranchpoints);
        /* ---------------------------------------------------------------- */
        /* create branchpointString */
        nmlCellBranchpointsString = mxCreateCellArray (1, iDimensions);
        mxSetCell (nmlCellBranchpointsString, 0, mxCreateString (nmlMemory));
        mxSetField (nmlStruct[0], 0, "branchpointsString", nmlCellBranchpointsString);
        /* reset memory pointer */
        gMemorypointer = 0;
        nmlMemory[gMemorypointer] = 0;
    } else {
        /* no branchpoints: initialize branchpointsString */
        nmlCellBranchpointsString = mxCreateCellMatrix (0, 0);
        mxSetField (nmlStruct[0], 0, "branchpointsString", nmlCellBranchpointsString);
    }

    /* print processing time */
    printf("Processing time: %d seconds.\n", time(NULL) - time_start);

    /* print success message */
    printf("File %s successfully imported.\n", szPathAndFilename);

    /* return cell */
    plhs[0] = nmlCell;
    return;
}
