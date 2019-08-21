function [stack, bbox] = convertKleeTracingToLocalStack( kn_tracing )

% Bounding Box (in global coordinates) from KLEE tracing
[kn_tracing, bbox] = findBBoxKLEE(kn_tracing);
% Go to local tracing (THE FAMOUS KLEE X/Y SWITCH IS UNDONE HERE & in changeToLocalTracing for tracing itself)
bboxTemp([1 2 3],:) = bbox([2 1 3],:);
kn_tracing = changeToLocalTracing(kn_tracing, bboxTemp(:,1));
% Preallocate stack matrix as unsigned integer
kn_stack = zeros(bboxTemp(:,2)' - bboxTemp(:,1)' + [1 1 1], 'uint8' );
% Create two grids which having the size of the bbox
[kn_gridx, kn_gridy] = ndgrid( 1:bboxTemp(1,2)-bboxTemp(1,1)+1, 1:bboxTemp(2,2)-bboxTemp(2,1)+1 );

for i=1:size( kn_tracing.contourList, 1 )
        kn_thiscont = getClosedContour( kn_tracing.contours{i});

        % Create a 2 dimensional matrix with 0 and 1, every pixel inside a
        % traced cell is 1. kn_gridx and kn_gridy determine the size,
        % kn_thiscont gives the shape of the polygon. Multiply with the
        % third column of contourList to ensure, that different cells have
        % different integer values.
        kn_inpoly = uint8(inpolygon(kn_gridx,kn_gridy,kn_thiscont(:,1),kn_thiscont(:,2))...
        	*kn_tracing.contourList(i,3));

        % Take the mean of the 3rd dimension of the tracing, to fit the
        % polygon into the stack.
        kn_thisz = nanmean(kn_thiscont(:, 3));

        if kn_thisz < 1 || kn_thisz > bboxTemp(3,2)-bboxTemp(3,1)+1
            warning('Contour out of z-Range');
        else
            % Check for replacing values (contour overlap)
            overlap = (kn_stack(:,:,kn_thisz) > 0) + (kn_inpoly > 0) > 1;
            pixel = sum(overlap(:));
            if pixel > 0
                if pixel > 200
                    %figure('position', [1601 1 1920 1079]);
                    %subplot(1,3,1); imagesc(kn_inpoly); axis equal; axis off; title('Contour to add to cuurent slice');
                    %subplot(1,3,2); imagesc(kn_stack(:,:,kn_thisz)); axis equal; axis off; title('Current slice in stack');
                    %subplot(1,3,3); imagesc(overlap); axis equal; axis off; title('Overlap between 1&2');
                    %colormap(autoKLEE_colormap);
                    %warning(['Contours overlap in z-plane ' num2str(kn_thisz)  '! ' num2str(pixel) ' pixel labeled as extracellular']);
                end
                newPlane = kn_stack( :, :, kn_thisz ) + kn_inpoly;
                newPlane(overlap) = 0;
            else
                newPlane = kn_stack( :, :, kn_thisz ) + kn_inpoly;
            end

            % Fit the polygon into the stack by adding the polygon to the
            % (zero)-stack.
            kn_stack( :, :, kn_thisz ) = newPlane;
        end
end

stack = zeros(size(kn_stack), 'uint32');
for i=1:max(kn_stack(:))
	bw = kn_stack == i;
    %bw = imerode(bw,ones(3,3,3));
	distBw = bwdist(bw) < 2 & ~bw;
	stack(bw) = i;
	setZero = distBw & stack ~= i;
	stack(setZero) = 0;
end

end

