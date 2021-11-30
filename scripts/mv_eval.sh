#!/bin/bash
#

cd '/home/hpl/multi-view-evaluation'


#./ETH3DMultiViewEvaluation --reconstruction_ply_path '/home/hpl/Documents/cysto3D/EndoVidSynthesis/data/Ms-Tsis_t10_s2+5/base_experiment/mesh/orig_point_cloud_post.ply' --ground_truth_mlp_path '/home/hpl/Documents/cysto3D/EndoVidSynthesis/data/templates/sgt.mlp' --tolerances 0.04

#./ETH3DMultiViewEvaluation --reconstruction_ply_path '/home/hpl/Documents/cysto3D/EndoVidSynthesis/data/Ms-Tsis_t10_s2+5/base_experiment/mesh/smooth_point_cloud_w_normals_post.ply' --ground_truth_mlp_path '/home/hpl/Documents/cysto3D/EndoVidSynthesis/data/templates/sgt.mlp' --tolerances 0.04

#./ETH3DMultiViewEvaluation --reconstruction_ply_path '/home/hpl/Documents/cysto3D/EndoVidSynthesis/data/Ms-Tsis_t10_s2+5/base_experiment/mesh/mesh_post.ply' --ground_truth_mlp_path '/home/hpl/Documents/cysto3D/EndoVidSynthesis/data/templates/sgt.mlp' --tolerances 0.04

#./ETH3DMultiViewEvaluation --reconstruction_ply_path '/home/hpl/Documents/cysto3D/EndoVidSynthesis/data/Ms-Tsis_t10_s2/base_experiment/mesh/orig_point_cloud_post.ply' --ground_truth_mlp_path '/home/hpl/Documents/cysto3D/EndoVidSynthesis/data/templates/sgt.mlp' --tolerances 0.04

#./ETH3DMultiViewEvaluation --reconstruction_ply_path '/home/hpl/Documents/cysto3D/EndoVidSynthesis/data/Ms-Tsis_t10_s2/base_experiment/mesh/smooth_point_cloud_w_normals_post.ply' --ground_truth_mlp_path '/home/hpl/Documents/cysto3D/EndoVidSynthesis/data/templates/sgt.mlp' --tolerances 0.04

#./ETH3DMultiViewEvaluation --reconstruction_ply_path '/home/hpl/Documents/cysto3D/EndoVidSynthesis/data/Ms-Tsis_t10_s2/base_experiment/mesh/mesh_post.ply' --ground_truth_mlp_path '/home/hpl/Documents/cysto3D/EndoVidSynthesis/data/templates/sgt.mlp' --tolerances 0.04

#./ETH3DMultiViewEvaluation --reconstruction_ply_path '/home/hpl/Documents/cysto3D/EndoVidSynthesis/data/Ms-Tsis_t10_s1+5/base_experiment/mesh/orig_point_cloud_post.ply' --ground_truth_mlp_path '/home/hpl/Documents/cysto3D/EndoVidSynthesis/data/templates/sgt.mlp' --tolerances 0.04

#./ETH3DMultiViewEvaluation --reconstruction_ply_path '/home/hpl/Documents/cysto3D/EndoVidSynthesis/data/Ms-Tsis_t10_s1+5/base_experiment/mesh/smooth_point_cloud_w_normals_post.ply' --ground_truth_mlp_path '/home/hpl/Documents/cysto3D/EndoVidSynthesis/data/templates/sgt.mlp' --tolerances 0.04

#./ETH3DMultiViewEvaluation --reconstruction_ply_path '/home/hpl/Documents/cysto3D/EndoVidSynthesis/data/Ms-Tsis_t10_s1+5/base_experiment/mesh/mesh_post.ply' --ground_truth_mlp_path '/home/hpl/Documents/cysto3D/EndoVidSynthesis/data/templates/sgt.mlp' --tolerances 0.04

#./ETH3DMultiViewEvaluation --reconstruction_ply_path '/home/hpl/Documents/cysto3D/EndoVidSynthesis/data/Ms-Tsis_t10_s1/base_experiment/mesh/orig_point_cloud_post.ply' --ground_truth_mlp_path '/home/hpl/Documents/cysto3D/EndoVidSynthesis/data/templates/sgt.mlp' --tolerances 0.04

#./ETH3DMultiViewEvaluation --reconstruction_ply_path '/home/hpl/Documents/cysto3D/EndoVidSynthesis/data/Ms-Tsis_t10_s1/base_experiment/mesh/smooth_point_cloud_w_normals_post.ply' --ground_truth_mlp_path '/home/hpl/Documents/cysto3D/EndoVidSynthesis/data/templates/sgt.mlp' --tolerances 0.04

#./ETH3DMultiViewEvaluation --reconstruction_ply_path '/home/hpl/Documents/cysto3D/EndoVidSynthesis/data/Ms-Tsis_t10_s1/base_experiment/mesh/mesh_post.ply' --ground_truth_mlp_path '/home/hpl/Documents/cysto3D/EndoVidSynthesis/data/templates/sgt.mlp' --tolerances 0.04

ex_dir='/home/hpl/Documents/cysto3D/EndoVidSynthesis/data/Ms-Tsis_t10_s1-Dm10c10/'
orig_dir=$ex_dir'/base_experiment/mesh/orig_point_cloud_post.ply'
smoo_dir=$ex_dir'/base_experiment/mesh/smooth_point_cloud_w_normals_post.ply'
mesh_dir=$ex_dir'/base_experiment/mesh/mesh_post.ply'
gt_dir='/home/hpl/Documents/cysto3D/EndoVidSynthesis/data/templates/sgt.mlp'
./ETH3DMultiViewEvaluation --reconstruction_ply_path $orig_dir --ground_truth_mlp_path $gt_dir --tolerances 0.04

./ETH3DMultiViewEvaluation --reconstruction_ply_path $smoo_dir --ground_truth_mlp_path $gt_dir --tolerances 0.04

./ETH3DMultiViewEvaluation --reconstruction_ply_path $mesh_dir --ground_truth_mlp_path $gt_dir --tolerances 0.04

# bash /home/hpl/Documents/cysto3D/EndoVidSynthesis/evs-3d/scripts/mv_eval.sh
