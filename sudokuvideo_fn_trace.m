function sudokuvideo_fn_trace(h,I0,I,pts)
%% Carry out the projective transform
try
T = cp2tform([1 1; 200 1; 200 200; 1 200],[pts(1:4,1),pts(1:4,2)],'projective');
I = imtransform(I,T,'XData',[1 460], 'YData',[1 460],'XYscale',1);

Imask = zeros(480,640);
Imask(10 + (1:460), 90+(1:460)) = I;
catch
end

%% This Section is where you actually do the overlaying.
% Depending on YUY2 or RGB, this may need changing
Imask = I0 .* uint8(~Imask);
set(h,'Cdata',cat(3,I0,Imask,I0));
set(h,'Cdatamapping','direct');
drawnow
