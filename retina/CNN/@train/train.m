%TRAIN class representing a trainging run for a cnn 
%   inputSize - input cube size
%   eta - Learning rate
%   savingPath - Folder for saving data generated during trainGradient      
%   maxIter - max number of iterations over samples
%   maxIterMini - max number of iterations within a sample

classdef train
    %TRAIN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % Parameter
        inputSize
        savingPath
        maxIter
        maxIterMini
        wStart
        bStart
        % Parameter with default value
        etaW=@(X)0.001;
        etaB=@(X)0.001;
        maxIterRandom = 100;
        GPU = true;
        local = false;
        iterations = 0;
        wghtTyp = @single;
        actvtTyp = @gsingle;
        saveTyp = @single;
        debug = false;
        debugLearn = false;
        percentageReqElem = 0.3;
        percentageReqEach = 0.3;
        constant_stepsize = false;
        costFunctionCutoff = true;
    end
    methods
        function obj = train(varargin)
            if(nargin~=0)
                obj.inputSize = varargin{1};            
                obj.etaW =@(it)varargin{2};
                obj.savingPath = varargin{3};
                obj.maxIter = varargin{4};
                obj.maxIterMini = varargin{5};
            end
        end
        function obj = setEtaWLinear(obj,etaStart,etaEnd)
            obj.etaW=@(i)etaStart+(etaEnd-etaStart)/(obj.maxIter*obj.maxIterMini)*i;
            obj.wStart = etaStart;
        end
        function obj = setEtaWExp(obj,etaStart,etaEnd)      
            obj.etaW=@(i)etaStart*exp(i*log(etaEnd/etaStart)/(obj.maxIter*obj.maxIterMini));
            obj.wStart = etaStart;
        end
        function obj = setEtaBLinear(obj,etaStart,etaEnd)
            obj.etaB=@(i)etaStart+(etaEnd-etaStart)/(obj.maxIter*obj.maxIterMini)*i;
            obj.bStart = etaStart;
        end
        function obj = setEtaBExp(obj,etaStart,etaEnd)      
            obj.etaB=@(i)etaStart*exp(i*log(etaEnd/etaStart)/(obj.maxIter*obj.maxIterMini));
            obj.bStart = etaStart;
        end
    end
end

