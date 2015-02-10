classdef train
    %TRAIN class representing a training run for a CNN
    % Input to constructor
    %   outputSize - input cube size
    %   savingPath - Folder for saving data generated during trainGradient      
    %   maxIter - max number of batch iterations
    %   wStart - Inital value for learning rate weights (for each layer)
    %   bStart - Inital value for learning rate biases (for each layer)
    
    properties
        % Parameter initalized in constructor
        outputSize
        savingPath
        maxIter
        wStart
        bStart
        % Parameter with default value
        iterations = 0;
        saveClass = @single;
        actvtClass = @gsingle;
        debug = false;
        linearRate = true;
    end
    methods
        % For additional methods (weight decay) see class folder (@train)
        function obj = train(varargin)
            if(nargin~=0)
                obj.outputSize = varargin{1};            
                obj.savingPath = varargin{2};
                obj.maxIter = varargin{3};
                obj.wStart = varargin{4};
                obj.bStart = varargin{5};
            end
        end
    end
end

