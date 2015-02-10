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
        filterSize
        run
        % Dependent parameters (calculated when calling initNet)
        randOfConvn
	numLayer
	layer
        % Parameter with default value
        normalize = true;
        % Anonymus functions and derivatives (loss func & nonlinearity)
        nonLinearity = @(x) 1.7159*tanh(0.66*x);
        nonLinearityD =@(x) 1.1325./(cosh(0.66*x).^2);
        lossFunction = @(x) 0.5*x.^2;
        lossFunctionD = @(x) x;
    end
    methods
        function cnet = cnn(varargin)
            if(nargin~=0)
                cnet.numHiddenLayer =  varargin{1};
                cnet.numFeature = varargin{2};
	        cnet.filterSize = varargin{3};
                cnet.run = varargin{4};
            end
        end
        % After calling init changing parameters passed into constructor might become obsolete!
        function cnet = init(cnet)
            cnet.numLayer = cnet.numHiddenLayer + 2;
            cnet.randOfConvn = (cnet.numHiddenLayer + 1) * (cnet.filterSize - 1);
            % One map in input and three maps in output layer
            cnet.layer{1}.numFeature = 1;
            for l=1:cnet.numHiddenLayer
                cnet.layer{l+1}.numFeature = cnet.numFeature(l);
            end
            cnet.layer{cnet.numHiddenLayer+2}.numFeature = 1;
            % Initalize Weights and Biases randomly
            for l=2:length(cnet.layer)
                cnet.layer{l}.W = cell(cnet.layer{l}.numFeature, 1);
		stdF = 1.3*3./prod(cnet.filterSize); % 1.3 due to std bias of nonlinearity, 3 empirical value
                for prevFm=1:cnet.layer{l-1}.numFeature
                    for fm=1:cnet.layer{l}.numFeature
                        cnet.layer{l}.W{prevFm,fm} = stdF*randn(cnet.filterSize); % 0.003 const stdF before change
                    end
                end
		cnet.layer{l}.B = zeros(1,cnet.layer{l}.numFeature);
            end
        end
    end
end
