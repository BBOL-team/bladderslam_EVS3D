%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Title:  bladderslam_EVS3D_generateTexture.m
%   Description:    Create bladder texture by drawing vasculature on an 
%                   existing texture.
%   Authors:    Rachel Eimen and Audrey K. Bowden
%   Organization:   Bowden Biomedical Optics Laboratory (BBOL)
%                   Vanderbilt Biophotonics Center (VBC)
%                   Vanderbilt University
%   Date:   2020-12-14
%   To Run: 1.  Change the path and filename for the input texture,
%               if necessary. The input texture is read into Img
%               on line 56.
%           2.  Change system parameter variables to modify the appearance
%               of the texture. System parameter variables are stored in I.
%           3.  Press "run" in MATLAB.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%------ BEGIN MAIN CODE
clear;  clc;    close all;

%% Initialize variables
%-------------------- I - system parameter variables ------------------
%{
% Image and image mask
%   I.Y - number of rows in the image of the inner half of the bladder
%   I.X - number of columns in the image of the inner half of the bladder
%   I.Img - image of the inner half of the bladder
%   I.validPointsMask - mask of locations where vasculature is valid
%
% Tree and branch appearance characteristics
%   I.MAX_VASCULATURE_COVERAGE - target number of desired painted pixels
%   I.MAX_BRANCHES_PER_NODE - max number of branches per node
%   I.MIN_TREE_LENGTH - min length of tree
%   I.MAX_OFFSET_TREE_LENGTH - max additional length of tree above min length
%   I.MAX_BRANCH_LENGTH - max length of branch
%   I.MAX_POLY_ORDER - max order of polynomials for branch creation
%   I.VESSEL_COLORMAP - selection of possible vessel pixel colors
%   I.MAX_BRANCH_WIDTH - max line-width of a tree/branch (tree and branches can have different widths)
%   I.MAX_BRANCHES_PER_TREE - limit total number of branches
%   I.BLUR_RATIO - divisor of the sigma of the gaussian used to blur
%   I.COLOR_AFTER_BLUR - Boolean to adjust the vasculature color after applying the blur
%
% Tracking variables for coverage
%   I.vasculatureCount - tracks how many pixels of "vasculature" have been painted
%   I.branchHistory - tracks number of branches on each tree
%   I.branchesDrawn - tracks number of total trees and branches drawn so far
%   I.vasculatureNodes - start nodes of trees
%   I.xDrawn - x-coordinates of drawn branches figure
%   I.yDrawn - y-coordinates of drawn branches figure
%   I.vasculatureMask - mask of locations of vasculature
%}

%-----------------------------------------
% Background texture of inner bladder wall
%-----------------------------------------
Img = imread('bladder_COLOR.png');
[I.Y,I.X,~] = size(Img);
I.X = floor(I.X/2);
I.Img = double(Img(1:I.Y, 1:I.X, :))/255;
I.validPointsMask = (sum(I.Img,3)>0);

figure(1);  subplot(1,3,1); imshow(I.Img);   title('Inner Bladder Texture'); hold on;

%---------------------------------
% Overall coverage characteristics
%---------------------------------
PERCENT_COVERAGE = 0.1;
I.MAX_VASCULATURE_COVERAGE = PERCENT_COVERAGE*sum(I.validPointsMask(:));

%-------------------------------------------
% Tree and branch appearance characteristics
%-------------------------------------------
I.MAX_BRANCHES_PER_NODE = 10;
I.MIN_TREE_LENGTH = 120;
I.MAX_OFFSET_TREE_LENGTH = 120;
I.MAX_BRANCH_LENGTH = 80;
I.MAX_POLY_ORDER = 5;
I.VESSEL_COLOR = [230 75 50]/255;
I.MAX_BRANCH_WIDTH = 6;
I.MAX_BRANCHES_PER_TREE = I.MAX_BRANCHES_PER_NODE;
I.BLUR_RATIO = 2;
I.BLUR = false;

%--------------------------------
% Tracking variables for coverage
%--------------------------------
I.vasculatureCount = 0;
I.branchHistory = [];
I.branchesDrawn = 0;
I.vasculatureNodes = [];
I.xDrawn = [];  I.yDrawn = [];
I.vasculatureMask = zeros([I.Y,I.X]);

%% Draw vasculature - each tree can have multiple branches
%---------------------------------------------------------------------
% Draw each tree until desired coverage is achieved (no pixels remain)
%---------------------------------------------------------------------
while I.vasculatureCount < I.MAX_VASCULATURE_COVERAGE
    %----------------------
    % Set starting position
    %----------------------
    [I.xStart,I.yStart] = startPosition(I.X,I.Y);

    while ~isValid(I,I.xStart, I.yStart)
        [I.xStart,I.yStart] = startPosition(I.X,I.Y);
    end
    
    %--------------------
    % Add to node history
    %--------------------
    I.vasculatureNodes(:,end+1) = [I.xStart;I.yStart];
    
    %-----------------------------------------
    % Draw a single tree at the start x and y
    %-----------------------------------------
    I = drawTree(I);
end

%-------------------------------------------------------------
% Show the vasculature mask and final texture with vasculature
%-------------------------------------------------------------
figure(1);  subplot(1,3,2); imshow(I.vasculatureMask);  title('Binary Vasculature Mask');
figure(1); subplot(1,3,3); imshow(I.Img);  title('Inner Bladder Texture - Vasculature');

%%------ END OF MAIN CODE

%% ----------------------------- drawTree() ----------------------------
%{
%   Description:    Determines number of branches to create from a given
%                   node and calls functions to draw the branches
%   Inputs:         I - system parameter variables
%   Outputs:        I - system parameter variables
%-----------------------------------------------------------------------%
%}
function I = drawTree(I)

    %-----------------------------------
    % Random number of branches per tree
    %-----------------------------------
    nBranches = round(rand()*I.MAX_BRANCHES_PER_TREE);
    
    %----------------------------------
    % Update number of branches to draw
    %----------------------------------
    I.branchHistory(end+1) = nBranches;
    
    %-------------------------------------------
    % Width of main branch in tree; minimum of 2
    %-------------------------------------------
    width = randi([2,I.MAX_BRANCH_WIDTH],1,1);
    I.width = width;
    
    %---------------------------------------------------------------
    % Draw main tree then its branches if there are pixels remaining
    %---------------------------------------------------------------
    if I.vasculatureCount < I.MAX_VASCULATURE_COVERAGE
        length = round(rand()*I.MAX_OFFSET_TREE_LENGTH+I.MIN_TREE_LENGTH);
        length = min([length I.MAX_VASCULATURE_COVERAGE-I.vasculatureCount]);
        
        %--------------------------------------------
        % Draw main tree and ID locs for branch nodes
        %--------------------------------------------
        [I, branchNodes] = drawBranch(I,length, I.xStart, I.yStart);
        
        %---------------------------------
        % Create branches if nBranches > 0
        %---------------------------------
        if branchNodes 
            %--------------------------------------------------------
            % Draw tree branches (shorter and thinner than main tree)
            %--------------------------------------------------------
            for ibranch = 1:nBranches
                I.width = round(width/(ibranch+1));
                length = round(rand()*I.MAX_BRANCH_LENGTH);
                [I,~] = drawBranch(I,length,branchNodes(1,ibranch),branchNodes(2,ibranch));
            end
        end
    end
    
    %--------------------------------
    % With each tree, update the mask
    %--------------------------------
    [maskDrawn,~,~,~] = indices(I,I.xDrawn,I.yDrawn);
    I.vasculatureMask(maskDrawn) = 1;
end

%% ---------------------------- drawBranch() ---------------------------
%{
%   Description:    Determines the coordinates for a branch of the tree
%                   at a given node
%   Inputs:         I - system parameter variables
%                   branchLength - Length of the branch to be drawn
%                   branchStartX - x coordinate of the starting point
%                       of the branch (the node)
%                   branchStartY - y coordinate of the starting point
%                       of the branch (the node)                     
%   Outputs:        I - system parameter variables
%                   branchNodes - Nodes of the branch
%-----------------------------------------------------------------------%
%}
function [I, branchNodes] = drawBranch(I,branchLength, branchStartX, branchStartY)

    %----------------------------------------------------
    % Number of branches at branchStartX and branchStartY
    %----------------------------------------------------
    nBranches = I.branchHistory(end);
    
    %---------------------------------------------
    % Empty matrix to hold the nodes of the branch
    %---------------------------------------------
    branchNodes = [];
    
    %--------------------
    % Create a polynomial
    %--------------------
    [x,y] = polynomial(I, branchLength);

    %------------------------------------
    % Reposition polynomial to node start
    %------------------------------------
    x = x + branchStartX;
    y = y + branchStartY;

    %-----------------------------------------------------
    % Cancel draw if any points are outside the valid area
    %-----------------------------------------------------
    if ~areValid(I, x, y)
        return;
    end
    
    %--------------------------
    % Otherwise, draw on figure
    %--------------------------
    I = drawVasculature(I,x,y);
    
    %--------------------------------
    % Update number of branches drawn
    %--------------------------------
    I.branchesDrawn = I.branchesDrawn + 1;

    %---------------------------------
    % Choose nodes for new vasculature
    %---------------------------------
    ibranchLocs = randi(length(x),1,nBranches);
    branchNodes = [x(ibranchLocs); y(ibranchLocs)];
       
end

%% ------------------------- drawVasculature() --------------------------
%{
%   Description:    Draws vasculature based on the input coordinates
%   Inputs:         I - system parameter variables
%                   x - x coordinates
%                   y - y coordinates
%   Outputs:        I - system parameter variables
%-----------------------------------------------------------------------%
%}
function I = drawVasculature(I,x,y)

    %-----------------------------------------
    % Interpolate to fill holes between points
    %-----------------------------------------
    x = round(interp(x,20));
    y = round(interp(y,20));

    %--------------------------------------------------
    % Widen branches to give the vasculature some width
    %--------------------------------------------------
    [x,y] = widenBranches(I,x,y);

    %-------------------------------------------------------------
    % Smooth the edges of vasculature and find new pixel locations
    %-------------------------------------------------------------
    mask = zeros([I.Y,I.X]);
    [maskDrawn,~,~,~] = indices(I,x,y);
    mask(maskDrawn) = 1;
    kernel = ones(4);
    tempMask = conv2(mask,kernel);
    mask = tempMask(1:I.Y,1:I.X);
    [y,x] = find(mask);
    y = transpose(y);   x = transpose(x);
    [maskDrawn,rDrawn,gDrawn,bDrawn] = indices(I,x,y);
    rDrawn = transpose(rDrawn); bDrawn = transpose(bDrawn); gDrawn = transpose(gDrawn); maskDrawn = transpose(maskDrawn);

    %-----------------------------------------------------
    % Cancel draw if any points are outside the valid area
    %-----------------------------------------------------
    if ~areValid(I,x,y)
        return;
    end
    
    %---------------------------------------------
    % Mark pixel locations in the vasculature mask
    %---------------------------------------------
    I.vasculatureMask(maskDrawn) = 1;

    %-------------------------------------
    % Get current image of bladder texture
    %-------------------------------------
    Img = I.Img;

    %---------------------------
    % Assign color to the pixels
    %---------------------------
    Img(rDrawn) = I.VESSEL_COLOR(1);
    Img(gDrawn) = I.VESSEL_COLOR(2);
    Img(bDrawn) = I.VESSEL_COLOR(3);
    
    %---------------
    % Blur the image
    %---------------
    if I.BLUR == true
        sigma = I.width/I.BLUR_RATIO;
        if sigma<0.1
            sigma = 1;
        end
        Img = imgaussfilt(Img,sigma);
    end
    
    %------------------------------------------
    % Put the blurred pixels in the final image
    %------------------------------------------
    I.Img(rDrawn) = Img(rDrawn);
    I.Img(gDrawn) = Img(gDrawn);
    I.Img(bDrawn) = Img(bDrawn);

    %---------------------------------------------------------
    % Add x and y coordinates to list of vasculature locations
    %---------------------------------------------------------
    I.xDrawn = [I.xDrawn, x];
    I.yDrawn = [I.yDrawn, y];
    
    I.vasculatureCount = I.vasculatureCount + numel(x);
end

%% ---------------------------- polynomial() ----------------------------
%{
%   Description:    Returns the y values for a polynomial generated with
%                   the x values of a odd degree between 3 and MAX.
%   Inputs:         I - system parameter variables
%                   branchLength - length of the branch to be created
%   Outputs:        xrot - x-axis values of the polynomial that is 
%                       rotated to a certain angle
%                   yrot - y-axis values of the polynomial that is 
%                       rotted to a certain angle
%-----------------------------------------------------------------------%
%}
function [xrot,yrot] = polynomial(I, branchLength)

    %--------------------------
    % Set default length to 101
    %--------------------------
    x = 0:100;
    y = ones(1,length(x));
    
    %-------------------------------------------------
    % Odd number of roots to give more realistic shape
    %-------------------------------------------------
    polyOrder = randi([1,floor((I.MAX_POLY_ORDER-1)/2)],1,1);
    polyOrder = 2*polyOrder + 1;

    %--------------------------------------------------------
    % Choose roots of polynomial to be within range -50 to 50
    %--------------------------------------------------------
    polyRoots = randi([min(x),max(x)],polyOrder,1);

    %------------------------------------------------------------------
    % Create polynomial function by multiplying out equation with roots
    %------------------------------------------------------------------
    for i = 1:length(polyRoots)
        y = y.*(x-polyRoots(i));
    end

    %----------------
    % Reset to origin
    %----------------
    y = y-y(1);

    %---------------------
    % Scale x and y values
    %---------------------
    height = max(y) - min(y);
    width = max(x) - min(x);
    y = y*branchLength/height;
    x = x*branchLength/width;

    %----------------------------------
    % Rotate polynomial by random angle
    %----------------------------------
    rotAngle = rand()*pi;
    xrot = x*cos(rotAngle) + y*sin(rotAngle);
    yrot = y*cos(rotAngle) - x*sin(rotAngle);
end


%% -------------------------- startPosition() --------------------------
%{
%    Description:   Returns the x and y coordinates of the parent node
%                   of the tree, or the starting point of the tree.
%    Inputs:        X - the number of columns in the image; in this 
%                       case, this is half of the original image
%                   Y - the number of rows in the image; in this 
%                       case, this is half of the original image
%    Outputs:       xStart - Random x coordinate between 1 and X
%                   yStart - Random y coordinate between 1 and Y
%-----------------------------------------------------------------------%
%}
function [xStart,yStart] = startPosition(X,Y)
    xStart = randi(X,1);
    yStart = randi(Y,1);
end

%% -------------------------- isValid() --------------------------
%{
%    Description:   Returns true if node points are within drawable area
%    Inputs:        I - system parameter variables
%                   nodeX - x coordinate to check for validity
%                   nodeY - y coordinate to check for validity
%    Outputs:       valid - validity of the coordinate
%-----------------------------------------------------------------------%
%}
function valid = isValid(I, nodeX, nodeY)

    %-------------------------------
    % Test if outside image boundary
    %-------------------------------
    [maxY, maxX] = size(I.validPointsMask);
    if (nodeX < 1 || nodeX > maxX || nodeY < 1 || nodeY > maxY)
        valid = false;
    
    %------------------------------------------------------------------
    % Return value of mask at point of interest; 0 = invalid, 1 = valid
    %------------------------------------------------------------------
    else
        valid = I.validPointsMask(round(nodeY),round(nodeX));
        
    end
end

%% -------------------------- areValid() --------------------------
%{
%    Description:   Returns true if all node points are within 
%                   drawable area
%    Inputs:        I - system parameter variables
%                   nodesX - x coordinates to check for validity
%                   nodesY - y coordinates to check for validity
%    Outputs:       valid - validity of the coordinates
%-----------------------------------------------------------------------%
%}
function valid = areValid(I, nodesX, nodesY)
    %----------------------------------
    % Test each coordinate for validity
    %----------------------------------
    valid = true;
    for node = 1:numel(nodesX)
        
        %------------------------------------------------------------
        % If a coordinate is invalid, mark all coordinates as invalid
        %------------------------------------------------------------
        if (~isValid(I,nodesX(node),nodesY(node)))
            valid = false;
            break;
        end
        
    end
end

%% -------------------------- indices() --------------------------
%{
%    Description:   Returns indices corresponding to input x and y
%                   coordinates. The maskDrawn contains indices in 
%                   the mask matrix, while the rDrawn, gDrawn, and 
%                   bDrawn contain indices in the red, green, and 
%                   blue bands of the image matrix
%    Inputs:        I - system parameter variables
%                   x - x-coordinates
%                   y - y-coordinates
%    Outputs:       maskDrawn - indices corresponding to x and y in the
%                       mask, which is size [I.Y,I.X]
%                   rDrawn - indices corresponding to x and y in the 
%                       mask, which is in [I.Y,I.X,1]
%                   gDrawn - indices corresponding to x and y in the 
%                       mask, which is in [I.Y,I.X,2]
%                   bDrawn - indices corresponding to x and y in the 
%                       mask, which is in [I.Y,I.X,3]
%-----------------------------------------------------------------------%
%}
function [maskDrawn,rDrawn,gDrawn,bDrawn] = indices(I,x,y)

    %-----------------------------------------------------------------
    % Round x and y coordinates and pin to edges if outside boundaries
    %-----------------------------------------------------------------
    xRound = round(x);
    xRound(xRound>I.X) = I.X;    xRound(xRound<1) = 1;
    yRound = round(y);
    yRound(yRound>I.Y) = I.Y;   yRound(yRound<1) = 1;

    %---------------------------------------------------------
    % Vasculature locations as indices (i.e., pixel locations)
    %---------------------------------------------------------   
    maskDrawn = sub2ind([I.Y,I.X],yRound,xRound);
    rDrawn = sub2ind([I.Y,I.X,3],yRound,xRound,ones(size(x)));
    gDrawn = sub2ind([I.Y,I.X,3],yRound,xRound,2*ones(size(x)));
    bDrawn = sub2ind([I.Y,I.X,3],yRound,xRound,3*ones(size(x)));
end

%% ------------------------- widenBranches() ---------------------------
%{
%    Description:   Changes pixel values to give lines at x and y a 
%                   uniform or non-uniform width
%    Inputs:        I - system parameter variables
%                   x - x-coordinates of a branch
%                   y - y-coordinates of a branch                 
%    Outputs:       x - x-coordinates of widened branch
%                   y - y-coordinates of a widened branch
%-----------------------------------------------------------------------%
%}
function [x,y] = widenBranches(I,x,y) 

    %--------------------------------
    % Get mask indices, given x and y
    %--------------------------------
    [maskIndices,~,~,~] = indices(I,x,y);
    
    %-----------------------------
    % Initialize mask with indices
    %-----------------------------
    mask = zeros([I.Y,I.X]);
    mask(maskIndices) = 255;
    
    if I.width<1
        I.width = 1;
    end

    %----------------------------------------------
    % Branches of width less than 10; uniform width
    %----------------------------------------------
    if I.width < 10
        kernel = ones(I.width);
        tempMask = conv2(mask,kernel);
        tempMask = double(tempMask(1:I.Y,1:I.X));
        mask = tempMask;

    %-----------------------------------------------
    % Branches of width 10 and up; non-uniform width
    %-----------------------------------------------
    else
        pixelWidths = 1:(I.width-1)/floor(numel(x)/2):I.width;
        for point = 1:floor(numel(x)/2)
            pointMask = zeros(size(mask));
            pointMask(y(point),x(point)) = 255;
            pointMask(y(end-point+1),x(end-point+1)) = 255;
            kernel = ones(round(pixelWidths(point)));
            pointMask = conv2(pointMask,kernel);
            pointMask = pointMask(1:size(mask,1),1:size(mask,2));
            mask = mask + pointMask;
        end
    end
    
    %--------------
    % Binarize mask
    %--------------
    mask = (mask>0);
    
    %--------------------------------------------------------------------
    % Smooth edges of lines to get rid of sharp corners and binarize mask
    %--------------------------------------------------------------------
    kernel = ones(I.width)/power(I.width,2);
    mask = conv2(single(mask),kernel,'same');
    mask = mask(1:size(mask,1),1:size(mask,2));
    mask = (mask>0.5);

    %-------------------------------------------------------------------
    % Find new coordinates of branch so they include pixels in the width
    %-------------------------------------------------------------------
    [y,x] = find(mask);
    x = transpose(x);   y = transpose(y);

end
