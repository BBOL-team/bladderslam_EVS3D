# evs-3d
This repository contains the Blender project files(.blend file, scripts and assets) for EVS-3D platform and evaluation code published in our paper: "Cost-efficient Video Synthesis and Evaluation for Development of Virtual 3D Endoscopy".

There are several highlights of this work:

1. 💡 We propose a new computer simulation tool designed as a plug-in to Blender, a free and open-source 3D computer graphics software, for cost-efficient generation of synthetic benchmarking endoscope videos and associated ground truths mimicking a variety of clinical scenarios. 

2. 💡 We also propose a comprehensive set of metrics that we suggest are necessary to reliably and correctly reflect the quality of reconstructed 3D models, reveal problematic steps in a given 3D reconstruction pipeline, and establish the working range of variables one might encounter in clinical use scenarios.

### Files structure
The repository is organized in the following structure:
***```EVS.blend```***: the Blender project file which packages assets links to scripts for EVS-3D and also provide Blender's built-in/native interfaces(3D vewport, object property interface etc.).

***```scripts``` folder***: contains all python code, matlab code, jupyter notebook required by using EVS-3D.

> ***```main.py```***: script-based frame rendering.

> ***```addon_evs.py```***: customized EVS-3D user panel GUI.

> ***```addon_temp.py```***: deprecated file.

> ***```all_eval.ipynb```***: jupyter notebook for getting evaluation metrics (APE, RPE, reprojection error for SFM, number of used views, etc.) for multiple reconstructions.

> ***```evo_eval.ipynb```***: jupyter notebook for getting evaluation metrics (APE, RPE) for one reconstruction.

> ***```grid_eval.ipynb```***: jupyter notebook for generating reconstruction for auxiliary model for evaluation of texture reconstruction quality.

> ***```grid_eval.sh```***: shell script for generating reconstruction for auxiliary model for evaluation of texture reconstruction quality.
> 
> ***```convert_frames2video.m```***: script for generating video file from synthesized frames.

> ***```create_curves.py```***: script for generating curve object representing camera movement trajectory. Deprecated file.

> ***```get_helpers.py```***: functions for getting camera parameters in simulator.

> ***```init_helpers.py```***: script for initialization of simulator.

> ***```set_helpers.py```***: functions for changing settings(camera trajectory, phantom model, etc.) in simulator.

> ***```mv_eval.sh```***: shell script for using multi-view-evaluation library to measure accuracy and completeness of reconstructed original pcl, smoothed pcl, mesh.

***```tex``` folder***: contains all texture images we've used throughout this study.
> ***```bladder_COLOR.png```***: texture image from a bladder phantom. The left half of the image corresponds to the inner surface of the bladder phantom; the right half corresponds to the outer surface. Note that this texture is low-resolution. 

> ***```bladder_NORM.png```***: direction image from a bladder phantom. This image helps adding details on shape that improves effect of lighting rendering, for example, the topological structure of muscles and bones will be more realistic. We didn't use this in experiemnts described in this paper. But users are free to utilize this image to further improve visual quality of simulation.

> ***```bladder_draw.png```***: synthesized texture image by using bladder_COLOR.png as background and programmatically drawing red lines on the left half to simulate vessel patterns on bladder inner surface.

> ***```bladder_grid.png```***: deprecated file.

> ***```bladder_pano.png```***: a high-resolution bladder panorama image which is generated from in-vivo cystoscope video and covers partial area within bladder.

> ***```bladder_mix.png```***: texture image by tiling bladder_pano.png on inner surface half of bladder_COLOR.png.

> ***```blue_grid.png```***:  texture image (multi-precision square grid on blue background) for auxiliary model for evaluation of reconstructed texture quality. 

> ***```blue_ngrid.png```***:  texture image (multi-precision grid pattern with recognizable shapes (i.e., letters, numbers in white and grid lines in black) on a blue background) for auxiliary model for evaluation of reconstructed texture quality. 

> ***```blue_ngrid_half.png```***:  blue_ngrid.png with reduced width so that it maps onto inner surface of the bladder phantom. 

> ***```grid_drawing.svg```***:  source file of the multi-precision square grid.

> ***```calib_target.png```***:  image for camera calibration. 

> ***```texture_rach.png```***:  deprecated file. Synthesized texture image by using bladder_COLOR.png as background and programmatically drawing red lines on the left half to simulate vessel patterns on bladder inner surface. Here vessel drawing used a different setting and didn't result in good contrast.

***```texture``` folder***: contains the texture image currently being used in the .blend project file.

***```generateTexture``` folder***: refer to README in https://github.com/BBOL-team/bladderslam_EVS3D/tree/main/generateTexture.

### Installation and Instruction:
> For frame synthesis, you need to download and install Blender v2.83.9.

>> If you want to use script-based frame rendering, open EVS.blend project file, then modify ***```main.py```*** as needed and run the script in Blender.

>> If you want to use GUI for frame rendering, run ***```addon_evs.py```*** and then use the generated EVS-3D user panel GUI in Blender. 

> For video generation, use ***```scripts/convert_frames2video.m```*** to convert all frames into a video file.

> For ground truth extraction, use model export interface in Blender to store the shape of phantom model, texture of auxiliary model and use ***```get_helpers.py```*** to store camera poses along the trajectory.

> For evaluation, you need to install evo library (https://github.com/MichaelGrupp/evo.git) and multi-view-evaluation library (https://github.com/ETH3D/multi-view-evaluation.git). Then use ***```evo_eval.ipynb```*** and ***```all_eval.ipynb```*** for evaluating quality of recovered camera pose, ***```mv_eval.sh```*** for evaluating quality of reconstructed shape,   ***```grid_eval.ipynb```*** and ***```grid_eval.sh```*** for evaluating quality of reconstructed texture.

### Citation
```
@InProceedings{Zhou2021evs-3d,
    author = {Zhou, Yaxuan and Eimen, Rachel L. and Seibel, Eric J. and Bowden, Audrey K.},
    title = {Cost-efficient Video Synthesis and Evaluation for Development of Virtual 3D Endoscopy},
    booktitle = {IEEE JTEHM},
    month = {},
    year = {2021}
}
```

