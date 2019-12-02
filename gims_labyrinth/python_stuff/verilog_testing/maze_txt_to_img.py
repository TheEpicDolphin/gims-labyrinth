import matplotlib.pyplot as plt
import numpy as np
import imageio

bin_maze = None
with open("bin_maze_img.txt", 'r') as f:
    bin_maze = (np.array(list(map(int, f.readlines()))).reshape(240,320) > 0).astype(int)

plt.figure()
plt.imshow(bin_maze, cmap='Greys')
plt.show()

imageio.imsave("../test_imgs/bin_maze_real.png", bin_maze)
