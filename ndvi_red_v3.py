
#Cambio en el ajuste de blancos, con filtro red de infragram
#se agrego el ajuste del parametro brillo
#se ajusto los parametros antes de la toma de la foto

import cv2
import numpy as np
import io
import picamera
import time
import sys

#Create a memory stream so photos doesn't need to be saved in a file
stream = io.BytesIO()

#Get the picture (low resolution, so it should be quite fast)
#Here you can also specify other parameters (e.g.:rotate the image)
with picamera.PiCamera() as camera:
    camera.start_preview()
    time.sleep(10)
    camera.shutter_speed = 500000 #values in microseconds 0-6000000
    camera.exposure_mode = 'off'
    camera.iso = 100 #values between 0-800 
    camera.awb_mode='off'
    camera.awb_gains=(0.56,1.27)
    camera.resolution = (1920, 1080)
    #camera.brightness = 20 #Values between 0-100
    camera.capture(stream, format='jpeg')
    

#Convert the picture into a numpy array
buff = np.fromstring(stream.getvalue(), dtype=np.uint8)

#Now creates an OpenCV image
img = cv2.imdecode(buff, 1)
cv2.imwrite('ngb.jpg',img)

#The order of matrix is in other different blue = [:,:,0], green = [:,:,1], red = [:,:,2]
#Suppose that NIR is in the channel blue by Rocco Filter
NIR = img[:,:,0]
green = img[:,:,1]
red = img[:,:,2]

#Convert the matrix in floating point of 32 bits
r = red.astype(np.float32)
nir = NIR.astype(np.float32)
# Tell numpy not to complain about division by 0:
np.seterr(invalid='ignore')
ndvi = (nir-r)/(nir+r) #calculate NDVI
ndviTrans = ndvi #Copy NDVI this way create other matrix with the same dimension

[m, n] = np.shape(ndvi) #get width and height number rows and colums
for i in xrange(1, m):
    for j in xrange(1,n):
        ndviTrans[i, j] = 127*(ndvi[i, j] + 1) #convert matrix of ndvi of -1 to 1 in 0 to 255
ndviTrans = np.uint8(ndviTrans)#change format to uint8

cv2.imwrite('ndvi.jpg',ndviTrans)
winname = 'ndvi'
#cv2.namedWindow(winname, cv2.WINDOW_NORMAL)
#ndviResize = cv2.resize(ndviTrans,(1000,640))
cv2.imshow(winname,ndviTrans)
cv2.waitKey(0)
cv2.destroyWindow(winname)

winname = 'ndvi with Color Map'
im_color = cv2.applyColorMap(ndviTrans, cv2.COLORMAP_JET)
cv2.imwrite('ndviColor.jpg',im_color)
cv2.imshow(winname,im_color)
cv2.waitKey(0)
cv2.destroyWindow(winname)
quit()
