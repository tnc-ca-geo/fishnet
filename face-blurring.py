"""
This script will take a csv file that contains bounding box information for faces contained in images, 
saves a copy of the original image, and blurs the face bounding box locations using a box filter defined by cv2.blur(). 
The expected format of the csv file is one row per face annotation, the first row contains header labels, with the following labels:

img_name - full path to the image file
bbox_id - not important
x_min - the x coordinate of the left edge of the face bounding box 
x_max - the x coordinate of the right edge of the face bounding box
y_min - the y coordinate of the top edge of the face bounding box
y_max - the y coordinate of the bottom edge of the face bounding box

The expected coordinate convention is the UL of image is 0,0
"""

import pandas as pd
import numpy as np
import cv2
import shutil
import matplotlib.pyplot as plt
import os
from tqdm import tqdm

# Directory to store duplicate images
DUPE_DIR = "/home/devuser/projects/fishnet/data/satlink/udz3-r2/faces/dupes/"
# Path to csv file containing face annotations
CSV_FILE = "/home/devuser/projects/fishnet/data/satlink/udz3-r2/faces/udz3-r2-faces-bbox.csv"

def calc_padded_box(img_face, img):
    '''Calculate bounding box location padded by 10%
    '''
    x1,x2,y1,y2 = [int(img_face.x_min),int(img_face.x_max),int(img_face.y_min),int(img_face.y_max)]
    #Add in 10% expansion here, and image edge safeguards
    x1 = int((x1 - (img_face.w) * 0.05, 0) [x1 - (img_face.w) * 0.05 < 0])
    x2 = int((x2 + (img_face.w) * 0.05, img.shape[1]) [x2 + (img_face.w) * 0.05 > img.shape[1]])
    y1 = int((y1 - (img_face.h) * 0.05, 0) [y1 - (img_face.h) * 0.05 < 0])
    y2 = int((y2 + (img_face.h) * 0.05, img.shape[0]) [y2 + (img_face.h) * 0.05 > img.shape[0]])
    return x1,x2,y1,y2

if __name__=="__main__":

    faces = pd.read_csv(CSV_FILE)
    faces['w'] = faces['x_max'] - faces['x_min']
    faces['h'] = faces['y_max'] - faces['y_min']
    unique_images = faces['img_name'].unique()

    for img_name in tqdm(unique_images):
        img_path,img_name = os.path.split(img_name)
        img_name = os.path.join(img_path,img_name)
        print(f"Processing image {img_name}")
        img_faces = faces.loc[faces['img_name'] == img_name]
        print(img_faces)
        dupe_fname = os.path.join(DUPE_DIR,img_name.split('/')[-1])
        shutil.copy2(img_name, dupe_fname)
        img = cv2.imread(img_name)
        for img_face in img_faces.itertuples():
            x1,x2,y1,y2 = calc_padded_box(img_face, img)
            img[y1:y2,x1:x2] = cv2.blur(img[y1:y2,x1:x2],(30,30))
        cv2.imwrite(img_name,img)

#Debug code for visualizing a bounding box
"""
cv2.rectangle(img,(x1,y1),(x2,y2),(255,0,0))
cv2.imshow("",img)
cv2.waitKey(0)
cv2.destroyAllWindows()
"""
