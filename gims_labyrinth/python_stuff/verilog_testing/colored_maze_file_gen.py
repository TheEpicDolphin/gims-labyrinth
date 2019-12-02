import matplotlib.pyplot as plt
import numpy as np
import imageio


def maze_file_gen(maze_im):
    f_contents = ""
    r, c, ch = maze_im.shape
    for i in range(r):
        for j in range(c):
            f_contents += '{:02x}'.format(maze_im[i,j,0]) + \
                            '{:02x}'.format(maze_im[i,j,1]) + \
                            '{:02x}'.format(maze_im[i,j,2]) + "\n"
            '''
            print(maze_im[i,j,:])
            print('{:02x}'.format(maze_im[i,j,0]) + \
                            '{:02x}'.format(maze_im[i,j,1]) + \
                            '{:02x}'.format(maze_im[i,j,2]))
            '''
    with open("maze_img.txt", 'w') as f:
        f.write(f_contents)
    return None

maze_im = imageio.imread("../test_imgs/real_maze.png")
maze_file_gen(maze_im)
