%CNN convolutional neural network class 
%   Input:
%    numHiddenLayer - total number of hidden layers
%    numFeature - feature maps per layer
%    filterSize - size of filter used by convn
%    numLabels - number of maps in output layer
classdef cnn
    properties
        % Parameters
        numHiddenLayer
        numFeature
        numLabels
        numLayer
        filterSize
        run
        % Dependent parameters (calculated when calling initNet)
        randOfConvn
        layer
        % Parameter with default value
        normalize = true;
        noRandomBias = true;
        masking=@(x)~isnan(x);
        isoBorder = 1;
        outputSize = [5 5 5];
        % Anonymus functions and derivatives (loss func & nonlinearity)
        nonLinearity = @(x) 1.7159*tanh(0.66*x);
        nonLinearityD =@(x) 1.1325./(cosh(0.66*x).^2);
        lossFunction = @(x,y) 0.5*(x-y).^2;
        lossFunctionD = @(x,y) (x-y);
    end
    methods
        function cnet = cnn(varargin)
            if(nargin~=0)
                cnet.numHiddenLayer =  varargin{1};
                cnet.numFeature = varargin{2};
                cnet.filterSize = varargin{3};
                cnet.numLabels = varargin{4};
            end
        end
        % After calling initNet changing parameters passed into constructor
        % becomes obsolete!
        function cnet = init(cnet)
            cnet.numLayer=cnet.numHiddenLayer+2;
            cnet.randOfConvn = (cnet.numHiddenLayer + 1) * (cnet.filterSize - 1);
            % One map in input and three maps in output layer
            cnet.layer{1}.numFeature = 1;
            for l=1:cnet.numHiddenLayer
                cnet.layer{l+1}.numFeature = cnet.numFeature;
            end
            cnet.layer{cnet.numHiddenLayer+2}.numFeature = cnet.numLabels;
            % Initalize Weights and Biases randomly
            for l=2:length(cnet.layer)
                cnet.layer{l}.W = cell(cnet.layer{l}.numFeature, 1);
                for prevFm=1:cnet.layer{l-1}.numFeature
                    for fm=1:cnet.layer{l}.numFeature
                        cnet.layer{l}.W{prevFm,fm} = randn(cnet.filterSize) ...
                            /(2*sqrt(prod(cnet.filterSize)));
                    end
                end
                if cnet.noRandomBias
                    cnet.layer{l}.B = zeros(1,cnet.layer{l}.numFeature);
                else
                    cnet.layer{l}.B = randn(1,cnet.layer{l}.numFeature);
                end
            end
        end
    end
    methods(Static)
        [target, mask] = probMask( currentTrace );
    end
end