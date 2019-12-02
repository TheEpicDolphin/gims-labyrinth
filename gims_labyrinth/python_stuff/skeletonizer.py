import matplotlib.pyplot as plt
import numpy as np
import imageio
from scipy import ndimage

# Load maze

im = (imageio.imread("test_imgs/bin_maze_real.png") > 0).astype(int)
#im = (imageio.imread("test_imgs/maze_complicated.bmp") > 0).astype(int)
#im = (imageio.imread("test_imgs/maze_denoised.png") > 0).astype(int)
#im = (imageio.imread("test_imgs/maze_thin_denoised.png") > 0).astype(int)

iterations = 100
r, c = im.shape

skel_img = np.copy(im)
for t in range(iterations):
    temp = np.copy(skel_img)
    for i in range(3, r - 3):
        for j in range(3, c - 3):
            #This part just makes sure that we keep the skeleton fully connected. 
            k = np.ravel(skel_img[i - 1 : i + 2, j - 1 : j + 2])
            n = k[[0,1,2,5,8,7,6,3]]
            n_s = np.roll(n, 1)
            changes = np.sum(np.logical_xor(n, n_s))
            if(changes > 2):
                continue

            #Apply kernels
            win = temp[i - 1 : i + 2, j - 1 : j + 2]
            h0 = win[0,0] == 0 and win[1,0] == 0 and win[2,0] == 0 and win[1,1] == 1 and win[0,2] == 1 and win[1,2] == 1 and win[2,2] == 1
            h1 = win[1,0] == 0 and win[2,0] == 0 and win[2,1] == 0 and win[0,1] == 1 and win[1,1] == 1 and win[1,2] == 1
            h2 = win[2,0] == 0 and win[2,1] == 0 and win[2,2] == 0 and win[0,0] == 1 and win[0,1] == 1 and win[1,1] == 1 and win[0,2] == 1
            h3 = win[2,1] == 0 and win[1,2] == 0 and win[2,2] == 0 and win[1,0] == 1 and win[0,1] == 1 and win[1,1] == 1
            h4 = win[0,2] == 0 and win[1,2] == 0 and win[2,2] == 0 and win[0,0] == 1 and win[1,0] == 1 and win[2,0] == 1 and win[1,1] == 1
            h5 = win[0,1] == 0 and win[0,2] == 0 and win[1,2] == 0 and win[1,0] == 1 and win[1,1] == 1 and win[2,1] == 1
            h6 = win[0,0] == 0 and win[0,1] == 0 and win[0,2] == 0 and win[2,0] == 1 and win[1,1] == 1 and win[2,1] == 1 and win[2,2] == 1
            h7 = win[0,0] == 0 and win[1,0] == 0 and win[0,1] == 0 and win[1,1] == 1 and win[2,1] == 1 and win[1,2] == 1
                
            skel_img[i, j] = temp[i, j] & ~(h0 or h1 or h2 or h3 or h4 or h5 or h6 or h7)

    
    #if(t % 10 == 0):
        #plt.figure()
        #plt.imshow(im, cmap='Greys')

        #plt.figure()
        #plt.imshow(skel_img, cmap='Greys')
        #plt.show()
    
    

plt.figure()
plt.imshow(im, cmap='Greys')

plt.figure()
plt.imshow(skel_img, cmap='Greys')
plt.show()

imageio.imsave("test_imgs/skel_real.png", skel_img)
#imageio.imsave("test_imgs/skel_complicated.png", skel_img)
#imageio.imsave("test_imgs/skel.png", skel_img)
#imageio.imsave("test_imgs/skel2.png", skel_img)
#imageio.imsave("test_imgs/skel_chain.png", skel_img)
