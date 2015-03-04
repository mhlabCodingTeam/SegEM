%% Create equalized version of these skeletons
skel{1} = parseNml('/home/mberning/localStorage/data/denseSkel/new/cortex_training_local.nml');
skel{2} = parseNml('/home/mberning/localStorage/data/denseSkel/new/cortex_test_local.nml');
skel{3} = parseNml('/home/mberning/localStorage/data/denseSkel/new/retina_training_local.nml');
skel{4} = parseNml('/home/mberning/localStorage/data/denseSkel/new/retina_test_local.nml');
skel = equalizeSkeletons(skel);
% save equalized skeletons and output statistics to text file
writeNml('/home/mberning/localStorage/data/denseSkel/new/cortex_training_local_ss.nml', skel{1});
writeNml('/home/mberning/localStorage/data/denseSkel/new/cortex_test_local_ss.nml', skel{2});
writeNml('/home/mberning/localStorage/data/denseSkel/new/retina_training_local_ss.nml', skel{3});
writeNml('/home/mberning/localStorage/data/denseSkel/new/retina_test_local_ss.nml', skel{4});
skeletonStatistics('/home/mberning/localStorage/data/denseSkel/new/');

%%
param.skel = skel{1};
paramTest.skel = skel{2};
visualizeOverviewComparison(param,paramTest);
