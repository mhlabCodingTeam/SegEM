function cnet = gradientPass(cnet, activity, sensitivity)
    
for layer=2:cnet.numLayer
    for prevFm=1:cnet.layer{layer-1}.numFeature
        for fm=1:cnet.layer{layer}.numFeature
            dW =  cnet.flipdims(convn(activity{layer-1,prevFm}, cnet.flipdims(sensitivity{layer,fm}), 'valid'));
            if cnet.run.constant_stepsize
                dW = dW ./ sum(abs(dW(:)));
            end
            cnet.layer{layer}.W{prevFm,fm} = cnet.run.wghtTyp(cnet.layer{layer}.W{prevFm,fm} - cnet.run.etaW(cnet.run.iterations) * dW);
        end
    end
    for fm=1:cnet.layer{layer}.numFeature
        dB =  sum(sensitivity{layer,fm}(:))/numel(sensitivity{layer,fm});
        cnet.layer{layer}.B(fm) = cnet.run.wghtTyp(cnet.layer{layer}.B(fm) - cnet.run.etaB(cnet.run.iterations) * dB);
    end
end
end