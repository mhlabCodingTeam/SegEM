function [target, mask] = probMask( currentTrace)
%PROBMASK Summary of this function goes here
%   Detailed explanation goes here
    target0=1==currentTrace;%-min(min(min(currentTrace)));
    %target=target/max(max(max(target)));
    mask0=ones(size(currentTrace));
    nPos=sum(sum(sum(target0==1)));
    nNeg=sum(sum(sum(target0==0)));
    mask0(target0==1)=(nNeg/nPos+1)/2;
    mask0(target0==0)=(nPos/nNeg+1)/2;
    target{1}=target0;
    mask{1}=mask0;
end

