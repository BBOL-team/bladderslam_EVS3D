# bladderslam_EVS3D_texture

The endoscopy virtual simulator three-dimensional (EVS3D) texture script creates bladder textures with vasculature characteristics defined by the user. The script begins with a base texture wih minimal vasculature (bladder_COLOR.png). Additional vasculature is then drawn on the inner bladder wall (the left half of the base texture). The script requires the installation of Matlab and the attached file containing the texture base image.

The script draws vasculature in the form of trees, with the tree characteristics randomly determined within a range of values defined by the user. The trees consist of a starting node with branches extending from the node and from points along the branches. The vasculature covers the inner bladder wall and does not intersect with the perimeter of the bladder wall.

![bladder_COLOR](https://user-images.githubusercontent.com/26093060/120930339-81daa380-c6b2-11eb-9841-7f6f0a7c0ea5.png)

## Requirements
* Matlab installation
* bladder_COLOR.png
* bladderslam_E3VS_generateTexture_v007.m

## Instructions to Run

Ensure bladderslam_E3VS_generateTexture_v007.m can access bladder_COLOR.png in one of two ways.

* Store bladderslam_E3VS_generateTexture_v007.m and bladder_COLOR.png in the same location and do not modify the following line of code (line 55).
```
Img = imread('bladder_COLOR.png');
```
* Store bladderslam_E3VS_generateTexture_v007.m and bladder_COLOR.png in different locations and modify the following line of code (line 55) to include the file path to bladder_COLOR.png.
```
Img = imread('bladder_COLOR.png')
```
The modified line will be in the form
```
Img = imread('<filePath>/bladder_COLOR.png')
```

Change the variables under **"Tree and branch appearance characteristics"** to modify the appearance of the bladder texture:


### Variables
The variables below define the appearance of the bladder texture.

* Image and image mask
  - I.Y - number of rows in the image of the inner half of the bladder
  - I.X - number of columns in the image of the inner half of the bladder
  - I.Img - image of the inner half of the bladder
  - I.validPointsMask - mask of locations where vasculature is valid

* Tree and branch appearance characteristics
  - I.MAX_VASCULATURE_COVERAGE - target number of desired painted pixels
  - I.MAX_BRANCHES_PER_NODE - max number of branches per node
  - I.MIN_TREE_LENGTH - min length of tree
  - I.MAX_OFFSET_TREE_LENGTH - max additional length of tree above min length
  - I.MAX_BRANCH_LENGTH - max length of branch
  - I.MAX_POLY_ORDER - max order of polynomials for branch creation
  - I.VESSEL_COLORMAP - selection of possible vessel pixel colors
  - I.MAX_BRANCH_WIDTH - max line-width of a tree/branch (tree and branches can have different widths)
  - I.MAX_BRANCHES_PER_TREE - limit total number of branches
  - I.BLUR_RATIO - divisor of the sigma of the gaussian used to blur
  - I.COLOR_AFTER_BLUR - Boolean to adjust the vasculature color after applying the blur

* Tracking variables for coverage
  - I.vasculatureCount - tracks how many pixels of "vasculature" have been painted
  - I.branchHistory - tracks number of branches on each tree
  - I.branchesDrawn - tracks number of total trees and branches drawn so far
  - I.vasculatureNodes - start nodes of trees
  - I.xDrawn - x-coordinates of drawn branches figure
  - I.yDrawn - y-coordinates of drawn branches figure
  - I.vasculatureMask - mask of locations of vasculature


## Flowchart

![bladderslam_cysto3D_bladderTexture_flowchart_v002](https://user-images.githubusercontent.com/26093060/120930543-56a48400-c6b3-11eb-9788-fc2c104c8eb3.png)

