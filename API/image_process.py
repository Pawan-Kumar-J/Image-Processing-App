from email.mime import image
import cv2
from PIL import Image, ImageFilter
# from io import BytesIO
import numpy as np 
from skimage.color import rgb2gray
from skimage.feature import corner_peaks, corner_harris




#None 
def edge_detect(img):
    ridge_detection2 = np.array([
    [-1, -1, -1],
    [-1, 8, -1],
    [-1, -1, -1]])
    ed = cv2.filter2D(img, ddepth = -1,kernel = ridge_detection2)    
    return ed


#Varun                       ## Image Path
def gaussianBlur(img, ksize = 5):
    # img = cv2.cvtColor(img,cv2.COLOR_BGR2RGB)
    blur = cv2.GaussianBlur(img,(ksize, ksize),20)
    return blur


#Om soni                     ## Image Path
def averaging(img, ksize = 5):    
    blur = cv2.blur(img,(ksize, ksize))
    return blur


#Sudhit
def negate(img):
    neg = 255-img
    return neg

# Karan
def opening(img, ksize = 5):
    def kernel_1(ksize):
        return np.ones((ksize, ksize),np.uint8)
    kernel = kernel_1(ksize)
    # open_img = cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)
    open_img = cv2.morphologyEx(img,cv2.MORPH_OPEN,kernel)
    return open_img

## Anuraag
def canny_edge(img, threshold1 = 50, threshold2 = 150, apertureSize=3, L2gradient=False):
    """Uses OpenCV built-in function for canny edge detection.
    The function finds edges in the input image and marks them in the output map edges using the Canny algorithm.
    The smallest value between threshold1 and threshold2 is used for edge linking.
    The largest value is used to find initial segments of strong edges
    Args:
        img (image): 8-bit source image
        threshold1 (float): first threshold for the hysteresis procedure
        threshold2 (float): second threshold for the hysteresis procedure
        apertureSize (int, optional): aperture size for the Sobel operator. Defaults to 3.
        L2gradient (bool, optional): a flag, indicating whether a more accurate L2 norm should be used to calculate
        the image gradient magnitude ( L2gradient=true ), or whether the default L1 norm is enough. Defaults to False.
    Returns:
        edges: _description_
    """
    # considering loaded image is not grayscale
    if len(img.shape) == 3:
        # converting 3D (default BGR) image array to 2D grayscale image array
        img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)    
    return cv2.Canny(img, threshold1, threshold2, apertureSize=apertureSize, L2gradient=L2gradient)

## Rishap Parmar 
def blackHat(images, ksize = 3):
    kernel = np.ones((ksize, ksize), np.uint8) 
    blc = cv2.morphologyEx(images,cv2.MORPH_BLACKHAT,kernel)
    return blc
    
## Aditya Gupta
def morph(img,ksize = 3):
    kernel = np.ones((ksize,ksize), np.uint8)
    img = cv2.morphologyEx(img, cv2.MORPH_GRADIENT, kernel) 
    return img

## Dhruv Jain 
def imageFunc(img, thresh = 150, max_value = 255):

    image = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    grayimage = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    xyz,im_blackwhite = cv2.threshold(grayimage, thresh, max_value, cv2.COLOR_BGR2RGB)
    return im_blackwhite

## Yatrik Shah
def erosion(img, iterations: int = 3, kernelSize: int = 3 ):
    image = img
    kernel = np.ones((kernelSize, kernelSize), np.uint8)
    image = cv2.erode(image, kernel, iterations=iterations) 
    return image

##Mithal Bhimani 
def dilation(img, ksize = 5, iterations = 3):
    kernel = np.ones((ksize, ksize), np.uint8)
    out = cv2.dilate(img, kernel, iterations)
    return out


##Vrushang Khalas
def sobel(img):
    if len(img.shape) > 1:
        image = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    else:
        image = img

    edge_x = np.array([
    [-1, -2, -1],
    [0,0,0],
    [1, 2, 1]
    ])
    edge_y = edge_x.T
    grady = cv2.filter2D(img, **{"ddepth":-1, "kernel":edge_x})
    gradx = cv2.filter2D(img ,**{"ddepth":-1, "kernel":edge_y})
    sobel = grady + gradx
    return sobel

##Krishna Panchal
def contrast_stretch(img,alpha=0,beta=1.2):
    
    norm_img2 = cv2.normalize(img, None, alpha=alpha, beta=beta, norm_type=cv2.NORM_MINMAX, dtype=cv2.CV_32F)
    norm_img2 = np.clip(norm_img2, 0, 1)
    norm_img2 = (255*norm_img2).astype(np.uint8)
    return norm_img2

##Himanshu pandya
def closing(image, ksize = 5):
    kernel = np.ones((ksize, ksize),np.uint8)
    close = cv2.morphologyEx(image, cv2.MORPH_CLOSE, kernel)
    return close

##Bhatt Rishit
def harris(img):
    imggray = rgb2gray(img)
    corners = corner_peaks(corner_harris(imggray), min_distance=5, threshold_rel = 0.02)

    for i, j in corners:
        cv2.circle(img, (j,i), radius = 1, color = (255, 0, 0), thickness = 5)
    return img

#Charchil
def maximum(img):
    img = Image.fromarray(img)
    max_img = img.filter(ImageFilter.MaxFilter(size = 3))
    
    return np.asarray(max_img)
1
#Keyur Desai
def median_blur(img, ksize = 3):
    img = cv2.medianBlur(img, ksize = ksize)
    return img

#Pathey
def laplacian(img, ksize = 3):
    img= cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    laplacian = cv2.Laplacian(img,-1, ksize = ksize,)
    return laplacian

#Mansuri Zakrariya
def sobel_scharr(img):
    vertical_k = np.array([[-3,0,3],
                            [-10,0,10],
                            [-3,0,3]])
    horizontal_k = np.array([[3,10,3],
                            [0,0,0],
                            [-3,-10,-3]])

    gauss_img = cv2.GaussianBlur(img,(5,5),0)
    vertical = cv2.filter2D(src = gauss_img, ddepth= -1, kernel= vertical_k)
    horizontal = cv2.filter2D(src = gauss_img, ddepth= -1, kernel= horizontal_k)

    vertical = np.absolute(vertical)
    horizontal = np.absolute(horizontal)
    sobel = vertical+horizontal

    return sobel

#Bajariya Vinay
def sharpen(img):
    kernel_sharpening = np.array([[-1,-1,-1], 
                              [-1,9,-1], 
                              [-1,-1,-1]])
    sharpened = cv2.filter2D(img, -1, kernel_sharpening)
    return sharpened