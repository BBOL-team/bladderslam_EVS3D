#!/bin/bash
#
cd '/home/hpl/cysto-3Dreconstruction/src/scripts/'

python2 texture_grid_gen_pipeline.py '/home/hpl/Documents/cysto3D/EndoVidSynthesis/data/Ms-Tsis_t10_s1+5/base_data/data_config.json'

python2 texture_grid_gen_pipeline.py '/home/hpl/Documents/cysto3D/EndoVidSynthesis/data/Ms-Tsis_t10_s2/base_data/data_config.json'

python2 texture_grid_gen_pipeline.py '/home/hpl/Documents/cysto3D/EndoVidSynthesis/data/Ms-Tsis_t10_s2+5/base_data/data_config.json'

#python2 texture_grid_gen_pipeline.py '/home/hpl/Documents/cysto3D/EndoVidSynthesis/data/Ms-Tsis_t10_s3/base_data/data_config.json'

