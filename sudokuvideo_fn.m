function sudokuvideo_fn()

%%%%%%%%%% Parameters you need to set: %%%%%%%%%%%%

% The initial threshold. Threshold at "bwthresh" times darker than the
% median in each block. Use the slider bar to adjust this in real time.
blksize = 92;  %blocksize for block processing /

% Specify whether to overlay the solution not. 1 or 0. /
tracking = 1;


% lines 14-16 of sudokuvideo_fn_trace.m. I'm not sure, my camera doesn't output RGB.
imaqreset
obj = videoinput('winvideo',1,'YUY2_640x480');

try
    
    %Initialize various parameters, and load in the template data
    load TEMPLATEDATA
    set(obj,'framesperTrigger',10,'TriggerRepeat',Inf);
    start(obj);
    
    A_tmin = 30; % Bounds for the digit pixel area
    A_tmax = 1000;
    digitbox_minarea = 20; % Bounds for the digit bounding box area
    digitbox_maxarea = 25^2;
    
    found = 0; % If a solution is FOUND, then start tracking.
    
    % h = The B/W image. h_g = Green box. h_pts = magenta box
    h = imshow(zeros(480,640));
    hold on;
    h_g = plot(90+[0 460 460 0 0],10+[0 0 460 460 0],'g');
    h_pts  = [];
    
    Plocal_old = []; % Variable to check the positions and values
    
    same = 0;
    samemax = 3; %Consecutive Matches
    
    figure(1);
    hslider = uicontrol('style','slider','units','n','pos',[0 0 1 0.05],'min',1.1,'max',1.4,'val',1.3);
    uicontrol('style','text','units','n','pos',[0 0.05 0.2 0.03],'String','Threshold adjustment:');
    
    while islogging(obj);
        
        bwthresh = get(hslider,'value');
        
        Icam = getdata(obj,1);
        
        
        Icam = Icam(:,:,1);
        
        % I0 represents only the inner green square
        I0 = Icam(10+(1:460),90+(1:460));
        flushdata(obj);
        
        %Block processed threshhold
        makebw2 = @(I) im2bw(I.data,median(double(I.data(:)))/bwthresh/255);
        IBW = ~blockproc(I0,[blksize blksize],makebw2);
        
        % Noise reduction and border elimination
        IBW = imclose(IBW,[1 1; 1 1]);
        I = IBW;
        I = bwareaopen(I,A_tmin);
        I = imclearborder(I);
        
        % Iout is an augmented 640x480 version of I, for display.
        Iout = zeros(480,640);
        Iout(10+(1:460),90+(1:460)) = I;
        
        % Show Iout
        if ~tracking || ~found
            set(h,'Cdata',Iout);
        end
        
        R = regionprops(I,'Area','BoundingBox','PixelList');
        NR = numel(R);
        
        % Find the largest object -> assume it to be the puzzle outline
        maxArea = 0;
        for k = 1:NR
            A(k) = prod(R(k).BoundingBox(3:4));
            if R(k).Area > maxArea
                maxArea = R(k).Area;
                kmax = k;
            end
        end
        figure(1);
        itsok = 0;
        if maxArea > 1000 && A(kmax) > 150^2 
            itsok = 1;
            set(h_g,'color','g');
            BBmax = R(kmax).BoundingBox;
            DIAG1 = sum(R(kmax).PixelList,2);
            DIAG2 = diff(R(kmax).PixelList,[],2);
            
            [m,dUL] = min(DIAG1);
            [m,dDR] = max(DIAG1);
            [m,dDL] = min(DIAG2);
            [m,dUR] = max(DIAG2);
            pts = R(kmax).PixelList([dUL dDL dDR dUR dUL],:);
            h_pts = plot(90+pts(:,1),10+pts(:,2),'m');
            
            XYLIMS = [BBmax(1) + [0 BBmax(3)] BBmax(2) + [0 BBmax(4)]];
        end
        
        % If we are in tracking mode, have found a solution, and still have a
        % bounding quadrilateral to work with, then call the overlay function
        if tracking && found && numel(pts) == 10 && polyarea(pts(1:4,1),pts(1:4,2)) > 150^2
            sudokuvideo_fn_trace(h,Icam,Iover,pts);
            try, delete(h_y); end; h_y = [];
            try, delete(h_pts); end; h_pts = [];
            continue
        end
        set(h,'Cdata',Iout);
        drawnow;
        
        % If a decent puzzle outline could not be found, then continue
        if ~itsok
            set(h_g,'color','r');
            continue
        end
        
        
        try, delete(h_y); end; h_y = [];
        try, delete(h_pts); end; h_pts = [];
        if found, continue; end
        
        h_digitcircles = [];
        kgood = zeros(1,NR);
        Pnew = zeros(NR,2);
        % Now we need to identify those blobs which are nearly digit sized,
        % and are inside our puzzle quadrilateral.
        for k = 1:NR
            if R(k).Area < A_tmax && A(k) > digitbox_minarea && A(k) < digitbox_maxarea ...
                    && R(k).BoundingBox(3) < 40 && R(k).BoundingBox(4) < 40 ...
                    && R(k).BoundingBox(3) > 2 && R(k).BoundingBox(4) > 2
                
                Pnew(k,:) = [R(k).BoundingBox(1)+R(k).BoundingBox(3)/2 R(k).BoundingBox(2)+R(k).BoundingBox(4)/2];
                
                
                if inpolygon(Pnew(k,1),Pnew(k,2),pts(:,1),pts(:,2))
                    h_digitcircles(k) = plot(90+Pnew(k,1),10+Pnew(k,2),'ro','markersize',24);
                    kgood(k) = 1;
                else
                    h_digitcircles(k) = plot(90+Pnew(k,1),10+Pnew(k,2),'bo','markersize',24);
                end
                
            end
        end
        [kgoodvals,kgoodlocs] = find(kgood);
        Pnew = Pnew(kgoodlocs,:);
        
        % This is where we send the remaining candidate blobs for
        % identification:
        % Plocal represents the puzzle as an Nx3 matrix: [x, y, digit]
        [Plocal,del] = identifynumbers_fun(pts,Pnew,NT,IBW);
        
        % Remove circles from non-digit locations
        try
            delete(h_digitcircles(kgoodlocs(del)));
            h_digitcircles(kgoodlocs(del)) = 0;
        catch
            keyboard
        end
        drawnow;
        try, delete(nonzeros(h_digitcircles)); end;
        
        % If good numbers were not identified, continue
        if isnan(Plocal)
            continue
        end
        
        % We need to wait until the identified digits are the same for a
        % specified number of times consecutively. If so, then call the
        % solver
        if isequal(Plocal_old, Plocal) && ~isempty(Plocal)
            same = same+1;
            if same == samemax-1
                title([num2str(same+1) ' / ' num2str(samemax)],'FontSize',12);
                M = zeros(9);
                for k = 1:size(Plocal,1)
                    M(Plocal(k,1),Plocal(k,2)) = Plocal(k,3);
                end
                M = M'
                M_sol = drawgraph(M);
                figure; imshow(I0);
                % If a solution was found, M_sol is non-empty.
                if ~isempty(M_sol)
                    if ~tracking, return; end
                    found = 1;
                    Iover = ~solution2image(M,M_sol); %Make the solution overlay
                    figure(1);
                else
                    same = 0;
                end
            end
        else
            same = 0;
        end
        
        title([num2str(same+1) ' / ' num2str(samemax)],'FontSize',12);
        Plocal_old = Plocal;
        
    end
catch
    % This attempts to take care of things when the figure is closed
    stop(obj);
    imaqreset
    %keyboard
    figure(1);
    imshow(get(h,'cdata'));
    drawnow;
end
