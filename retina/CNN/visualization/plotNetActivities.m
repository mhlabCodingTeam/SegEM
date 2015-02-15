function plotNetActivities( struct, iter )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

[dataRaw, dataTrace] = getKleeStackList();
fields = fieldnames(struct);
for i=1:length(fields)
    display(['Starting net ' num2str(i,'%i') ' out of ' num2str(length(fields), '%i')  ' in total.']);
    if nargin == 1
        [cnet, ~] = loadSingleCNN(['/path/to/some/directory/fermatResults/' struct.(fields{i}).date '/net' num2str(struct.(fields{i}).rand, '%6.6u') '/']);
    else
        [cnet, ~] = loadSingleCNN(['/path/to/some/directory/fermatResults/' struct.(fields{i}).date '/net' num2str(struct.(fields{i}).rand, '%6.6u') '/'], iter);
    end
    % Determine region of fwdPass
    stackNr = 38; % 1 altes setting
    nrPlanes = [5 5 5];
    inputSize = [255 255 63];
    randEdge = [1 1 100];
    % Prepare raw and trace stacks
    load(dataRaw{stackNr});
    load(dataTrace{stackNr});
    raw = kl_roi;
    trace = kl_stack;
    
    cnet.run.actvtTyp = @double;
    if cnet.normalize
        raw = cnet.normalizeStack(single(raw));
    end
    % Adjust sizes & run fwdPass
    inputPatch=cell(1,3);
    outputPatch=cell(1,3);
    for dim=1:3
        inputPatch{dim} = randEdge(dim):randEdge(dim) + inputSize(dim) - 1;
        outputPatch{dim} = inputPatch{dim}(ceil(cnet.randOfConvn(dim)/2):end - ceil(cnet.randOfConvn(dim)/2));
    end
    currentTrace = trace(outputPatch{:});
    [target, mask] = cnet.masking(cnet, currentTrace);
    currentRaw = raw(inputPatch{:});
    [activity, ~] = cnet.fwdPass3D(currentRaw);
    
    if isempty(mask{1})
        load('/path/to/some/directory/e_k0563/vesicle/Masks/e_k0563_ribbon_0124b_vesicles_full_stack_mask.mat');
        mask{1} = KLEE_savedStack(outputPatch{:});
        mask{1}(1,:,:) = [];
        mask{1}(:,1,:) = [];
        mask{1}(:,:,1) = [];
    end
    
    % Plot results (in background)

    % Plot activity earlier layers?
    figure('Visible', 'off');
    hold on;
    for l=1:size(activity, 1)
        for fm=1:size(activity, 2)
            if ~isempty(activity{l,fm})
                subplot(size(activity, 2), size(activity, 1), (fm-1)*size(activity, 1)+l);
                temp = double(activity{l,fm});
                imagesc(temp(:,:,nrPlanes(1)+(size(activity, 1)-l)*cnet.filterSize(3)/2));
                colormap(gray);
                axis off;
                caxis([-1.7, 1.7]);
            end
        end
    end
    % Save to PDF file in sync folder
    set(gcf, 'PaperPosition', [0 0 10 15]);
    set(gcf, 'PaperSize', [10 15]);
    
    if ~exist(['/path/to/some/directory/sync/toP1-377/PDF/' struct.(fields{i}).date '/'], 'dir')
        mkdir(['/path/to/some/directory/sync/toP1-377/PDF/' struct.(fields{i}).date '/']);
    end
    print('-dpdf', ['/path/to/some/directory/sync/toP1-377/PDF/' struct.(fields{i}).date '/netAct' num2str(struct.(fields{i}).rand, '%6.6u') '.pdf']);
    close all;
    
    % Plot final + target*mask + raw
    figure('Visible', 'off');
    hold on;
    subplot(3,3,4);
    temp = double(activity{size(activity,1),1});
    imagesc(temp(:,:,nrPlanes(1)));
    axis off;
    caxis([-1, 1]);
    title('xAff');
    
    subplot(3,3,7);
    imagesc(double(target{1}(:,:,nrPlanes(1))).*double(mask{1}(:,:,nrPlanes(1))));
    axis off;
    caxis([-1, 1]);
    title('xTarget');
    
    subplot(3,3,1);
    imagesc(raw(outputPatch{1},outputPatch{2},outputPatch{3}(nrPlanes(1))+1));
    colormap(gray);
    title('raw');
    axis off;
    
    if ~isempty(activity{size(activity,1),2})
        
        subplot(3,3,5);
        temp = double(activity{6,2});
        imagesc(temp(:,:,nrPlanes(2)));
        axis off;
        caxis([-1, 1]);
        title('yAff');

        subplot(3,3,8);
        imagesc(target{2}(:,:,nrPlanes(2)).*mask{2}(:,:,nrPlanes(2)));
        axis off;
        caxis([-1, 1]);
        title('yTarget');

        subplot(3,3,2);
        imagesc(raw(outputPatch{1},outputPatch{2},outputPatch{3}(nrPlanes(2))+1));
        colormap(gray);
        title('raw');
        axis off;

        subplot(3,3,6);
        temp = double(activity{6,2});
        imagesc(squeeze(temp(:,nrPlanes(3),:)));
        axis off;
        caxis([-1, 1]);
        title('zAff');

        subplot(3,3,9);
        imagesc(squeeze(target{2}(:,nrPlanes(3),:).*mask{2}(:,nrPlanes(3),:)));
        axis off;
        caxis([-1, 1]);
        title('zTarget');

        subplot(3,3,3);
        imagesc(squeeze(raw(outputPatch{1},outputPatch{2}(nrPlanes(3)+1),outputPatch{3})));
        colormap(gray);
        title('raw');
        axis off;
    
    end
    
    % Mark for reference in combined PDF
    text(0.2, 1.2, ['net' num2str(struct.(fields{i}).rand, '%6.6u')]);
    
    % Save to PDF file in sync folder
    set(gcf, 'PaperPosition', [0 0 10 10]);
    set(gcf, 'PaperSize', [10 10]);
    
    if ~exist(['/path/to/some/directory/sync/toP1-377/PDF/' struct.(fields{i}).date '/'], 'dir')
        mkdir(['/path/to/some/directory/sync/toP1-377/PDF/' struct.(fields{i}).date '/']);
    end
    print('-dpdf', ['/path/to/some/directory/sync/toP1-377/PDF/' struct.(fields{i}).date '/net' num2str(struct.(fields{i}).rand, '%6.6u') '.pdf']);
    close all;
end

