import matplotlib.pyplot as plt
import numpy as np
import imageio

'''
bin_maze = None
with open("bin_maze_img.txt", 'r') as f:
    bin_maze = (np.array(list(map(int, f.readlines()))).reshape(240,320) > 0).astype(int)

plt.figure()
plt.imshow(bin_maze, cmap='Greys')
plt.show()

imageio.imsave("../test_imgs/bin_maze_real.png", bin_maze)
'''
bin_maze = None
with open("bin_maze_img.txt", 'r') as f:
    bin_maze = (np.array(list(map(int, f.readlines()))).reshape(240,320) > 0).astype(int)

bin_maze_eroded = None
with open("bin_maze_eroded_img.txt", 'r') as f:
    bin_maze_eroded = (np.array(list(map(int, f.readlines()))).reshape(240,320) > 0).astype(int)


bin_maze_dilated = None
with open("bin_maze_dilated_img.txt", 'r') as f:
    bin_maze_dilated = (np.array(list(map(int, f.readlines()))).reshape(240,320) > 0).astype(int)


plt.figure()
plt.imshow(bin_maze, cmap='Greys')

plt.figure()
plt.imshow(bin_maze_eroded, cmap='Greys')


plt.figure()
plt.imshow(bin_maze_dilated, cmap='Greys')

plt.show()
