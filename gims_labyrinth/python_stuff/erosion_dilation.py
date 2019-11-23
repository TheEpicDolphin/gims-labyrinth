import matplotlib.pyplot as plt
import numpy as np
import imageio
from scipy import ndimage

# Load maze

#im = (imageio.imread("test_imgs/maze_thin.bmp") > 0).astype(int)
im = (imageio.imread("test_imgs/maze_gen.bmp") > 0).astype(int)
#im = (imageio.imread("test_imgs/maze_noiseless.bmp") > 0).astype(int)

iterations = 5
r, c = im.shape
kernel_shape = (7,7)

eroded = np.copy(im)
for i in range(3, r - 3):
    for j in range(3, c - 3):
        win = im[i - 3 : i + 4, j - 3 : j + 4]
        eroded[i, j] = np.all(win)


dilated = np.copy(eroded)
for i in range(3, r - 3):
    for j in range(3, c - 3):
        win = eroded[i - 3 : i + 4, j - 3 : j + 4]
        if(eroded[i,j] == 1):
            dilated[i - 3 : i + 4, j - 3 : j + 4] = np.ones(kernel_shape)

plt.figure()
plt.imshow(im, cmap='Greys')

plt.figure()
plt.imshow(eroded, cmap='Greys')

plt.figure()
plt.imshow(dilated, cmap='Greys')

plt.show()
#imageio.imsave("test_imgs/maze_denoised.png", eroded)
imageio.imsave("test_imgs/maze_thin_denoised.png", eroded)

