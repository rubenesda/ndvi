# ndvi
Scripts extras 
This code in language Python capture a image from Raspberry Pi in encoded .jpg in a type of image in format uint8, the image has the red visible and near infra-red band, after the variable save this image and next it is converted in a float (may be flot16, float32, float64, doesn't matter) array for calculate the NDVI:

         NDVI = (NIR - R)/(NIR + R)


The result must be converted again in format uint8 and the change of range values of NDVI of -1 to 1 to 0 - 255 (format uint8) for can be visualize in a canvas or write in a file .jpg.

###### The file ndvi_red_v3.py
This is develop of code progress day to day and experiment by experiment.

###### File ndvi_red_proof_png.py
This is experiment code for observate the diffenrence the two image between a adjust fix on Raspberry and other follow that Raspberry use automatic adjust.


