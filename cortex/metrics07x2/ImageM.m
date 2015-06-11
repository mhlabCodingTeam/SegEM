classdef ImageM
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    
    methods
        function obj=ImageM(jarname)
            javaaddpath(jarname);
            imagej=ij.ImageJ([],1);
        end
        function image(obj,data)
            sd=size(data);
            ij.IJ.newImage('image','8-bit',sd(1),sd(2),1);
            gi=ij.IJ.getImage();
            gp=gi.getProcessor();
            gp.setPixels(data(:));
            gi.updateAndDraw();
        end
        function stack(obj,data)
            sd=size(data);
            ij.IJ.newImage('stack','8-bit',sd(1),sd(2),sd(3)+1);
            gi=ij.IJ.getImage();
            gs=gi.getStack();
            for i=1:sd(3)
                dataL=data(:,:,i);
                gs.setPixels(dataL(:),i+1);
            end
        end
    end
end