function fig = TrackingMovie(imagerData,WindowLevel,trackedPts,opt)
%TRACKINGMOVIE: shows tracking data over top of images
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Jakob Marshall, Feb 2023
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%% Input Arguments: %%%%%%%%%
    %imagerData: Cell array of fluoro images             (1xnFrames) or (1x1 cell array) or (2D image array)
    %WindowLevel: Window to show image contrast          (1x2)
    %trackedPts: tracked points                          (nFrames x 2 x nTracked)
    %opt: Options for fnc structure with:
       %opt.markerType: '.' or 'o' type of marker to plot                 (char)
       %opt.markerColor: color triplet array of color for each lead       (nLeads x 3)
       %opt.savePath: path to write gif to
       %opt.legendNames: Name of each tracked object to display in legend 
%
%%%%%%%%% Output Arguments: %%%%%%%%%
    %fig: created figure object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
nFrames = size(trackedPts,1);
nLeads = size(trackedPts,3);

%Check size of tracked Pts
if ~(size(trackedPts,2) == 2)
    error('Size of TrackedPts not consitent')
end
%if only one image is input, plot all based on that image
singleImage = 0;
if ~iscell(imagerData)  
    singleImage = 1;
elseif numel(imagerData) == 1
    singleImage = 1;
    imagerData = imagerData{1};
end

%Check inputs
    if isfield(opt,'markerColor')
        markerColor = opt.markerColor;
    else
        markerColor = get(gca,'colororder');
    end
    if isfield(opt,'markerSize')
        markerSize = opt.markerSize;
    else
        markerSize = 25;
    end
    
    if nLeads>size(markerColor,1)
        duplicationFactor = ceil(nLeads/size(markerColor,1));
        markerColor = repmat(markerColor,duplicationFactor,1);
    end
    
    if isfield(opt,'markerType')
        markerType = opt.markerType;
    else 
        markerType = 'o';
    end

    if isfield(opt,'savePath')
        opt.save = 1;
    end
    
    if isfield(opt,'legendNames')
        opt.legend = 1;
    else
        opt.legend = 0;
    end

%Initiate figure
fig = figure;
fig.Position = [1028, 108, 799, 990];
axis tight manual % this ensures that getframe() returns a consistent size


if opt.save
    filename = [opt.savePath,'.gif'];
end
    for f = 1:nFrames%for each frame
    
        colormap gray
            if singleImage 
                imagesc(imagerData,WindowLevel)
            else
                imagesc(imagerData{f},WindowLevel)
            end
        hold on
            for lead = 1:nLeads
                plot(trackedPts(f,1,lead),trackedPts(f,2,lead),markerType,'Color',markerColor(lead,:),'MarkerSize',markerSize)
            end
        axis image
        axis off
            if opt.legend
                legend(opt.legendNames)
            end
      
        if opt.save
         frame = getframe(fig); 
          im{f} = frame2im(frame); 

        end
    end

    if opt.save
        for f = 1:nFrames
            [imind,cm] = rgb2ind(im{f},256); 
            % Write to the GIF File 
            if f == 1 
                imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
            else 
                imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.2); 
            end 
        end
    end

end
