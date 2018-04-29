# Face replacement

Authors:
- Aditya Gourav
- Dhruva Kumar

The goal of the project is to automatically detect and seamlessly replace all the faces in an image with a reference face. The pipeline for face replacement in images is then extended to videos. This was the final project for [CIS 581 Computer vision and computational photography](www.seas.upenn.edu/~cis581) done in 2014.

## Project pipeline and results

[pdf](./cis581_final_ppt.pdf)

Results of face replacement in video: https://www.youtube.com/watch?v=DwmR5lUuXT4

## Usage

Run `main.m`

## Description of files

- `main.m` - wrapper file which calls `face_replace.m` with the input image/video and the face to replace

- `face_replace.m` - Replaces the face(s) in image/video and displays it. (The video is saved as `result.avi`)

- `extafacedescs.m` - wrapper to call 3rd party lib to extract facial feature points

- `getConvHull.m` - our function, calculates the angle at which the face is inclined to with the vertical and a label for pose (left, frontal, right) using geometry. It then also estimates some points on the face which form a convex hull without cutting out the person's eyebrow

`ref_images.mat` - library of reference faces in different poses


