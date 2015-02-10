SegEM: Semi automated image analysis toolkit for Connectomics
========================================

Usage
---------

Just provide requested information on top of startup.m and start Matlab from main folder of this repository

Then choose whether you want to work with retina or cortex (version of code and data)

This will open relevant scipts which can be executed from top to bottom using Ctrl+Enter
See “Cell Mode” in Matlab help for more information

The most important parts of the code for CORTEX are (always including some visualization):
+ cnnStart: load training data, train a convolutional neuronal network, paralell network training, selection and variation
+ mainSegCortex: steps from classification result by CNN to segmentation (parameter search for watershed segmentation) including skeleton based split-merger metrics
+ bigFwdPassStart: Apply learned CNN classifier (learned in point 1) and watershed segmentation steps (with parameters optimized in 2)
+ galleryCortexStart: Use segmentation of whole dataset (point 3) with skeleton reconstructions for volume reconstructions
+ contactDetectionCortexStart: Contact detection between cell pairs based on skeleton reconstructions and segmentation of whole dataset

The most important parts of the code for RETINA are:

