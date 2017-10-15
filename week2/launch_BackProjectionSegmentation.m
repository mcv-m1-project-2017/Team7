[perceptual_info] = BackProjectionTrain('/home/mcv00/DataSet/4c/train', 32);

%Generate masks without noise reduction
BackProjectionSegmentation('/home/mcv00/DataSet/4c/train', 'BackProjMasks', perceptual_info, 0.25, 0);

%Generate masks with noise reduction
BackProjectionSegmentation('/home/mcv00/DataSet/4c/train', 'BackProjMasks', perceptual_info, 0.25, 1);
