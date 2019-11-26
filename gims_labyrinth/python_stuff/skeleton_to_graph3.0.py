import matplotlib.pyplot as plt
import numpy as np
import imageio
from scipy import ndimage
from collections import deque

# Load maze

skel_img = (imageio.imread("test_imgs/skel.png") > 0).astype(int)

r, c = skel_img.shape
graph_img = np.copy(skel_img)
graph_img.astype(np.uint8)

intersection_nodes = []
#Find all intersections. These will be nodes in the graph
for i in range(3, r - 3):
    for j in range(3, c - 3):
        win = skel_img[i - 1 : i + 2, j - 1 : j + 2]
        intersection = win[1,1] == 1 and \
                       ((win[0,1] == 1 and win[2,1] == 1 and win[1,2] == 1) or \
                       (win[1,0] == 1 and win[2,1] == 1 and win[1,2] == 1) or \
                       (win[1,0] == 1 and win[0,1] == 1 and win[1,2] == 1) or \
                       (win[1,0] == 1 and win[0,1] == 1 and win[2,1] == 1))
        if(intersection):
            intersection_nodes.append([j,i])
            graph_img[i, j] = 2

print(intersection_nodes)

plt.figure()
plt.imshow(skel_img, cmap='Greys')

plt.figure()
plt.imshow(skel_img, cmap='Greys')
plt.scatter(*zip(*intersection_nodes))
plt.show()

#Now, run simplified dfs from each node and create edges to other nodes. If we encounter any corners along the way, put down more nodes


MAX_SPACING = 10
cooldown = 0

MAX_POS_SIZE = 15
CORNER_THRESHOLD = 150
STRAIGHT_THRESHOLD = 160

STRAIGHT_MODE = 0
CORNER_MODE = 1
state = None

nodes = [intersection_node for intersection_node in intersection_nodes]

neighbor_offsets = [(1,0),(0,1),(-1,0),(0,-1)]
for intersection_node in intersection_nodes:
    j, i = intersection_node
    for offset in neighbor_offsets:
        last_visited = [[i,j]]
        cur = [i + offset[0], j + offset[1]]
        corner_thetas = []
        corner_points = []
        local_pos = deque()
        state = STRAIGHT_MODE
        while(cur[0] > 3 and cur[0] < r - 3 and cur[1] > 3 and cur[1] < c - 3):
            #print("last visited:", last_visited)
            #print("current:", cur)
            local_pos.append(cur)
            if(len(local_pos) > MAX_POS_SIZE + 1):
                local_pos.popleft()
                v1 = np.array([local_pos[0][1], local_pos[0][0]]) - np.array([local_pos[MAX_POS_SIZE//2][1], local_pos[MAX_POS_SIZE//2][0]])
                v2 = np.array([local_pos[MAX_POS_SIZE][1], local_pos[MAX_POS_SIZE][0]]) - np.array([local_pos[MAX_POS_SIZE//2][1], local_pos[MAX_POS_SIZE//2][0]])
                cos_theta = np.dot(v1, v2)/(np.linalg.norm(v1) * np.linalg.norm(v2))
                theta = np.arccos(cos_theta) * 180/np.pi
                print(theta)
                if(state == STRAIGHT_MODE):
                    if(theta < CORNER_THRESHOLD):
                        state = CORNER_MODE
                        cooldown = MAX_SPACING
                        
                elif(state == CORNER_MODE):
                    if(theta > STRAIGHT_THRESHOLD):
                        state = STRAIGHT_MODE
                    if(cooldown >= MAX_SPACING):
                        nodes.append([local_pos[MAX_POS_SIZE//2][1], local_pos[MAX_POS_SIZE//2][0]])
                        cooldown = 0
                    cooldown += 1

            #left
            n1 = [cur[0], cur[1] - 1]
            #right
            n2 = [cur[0], cur[1] + 1]
            #up
            n3 = [cur[0] - 1, cur[1]]
            #down
            n4 = [cur[0] + 1, cur[1]]
            
            temp = cur
            if(n1 != last_visited and graph_img[n1[0],n1[1]] == 1):
                cur = n1
            elif(n2 != last_visited and graph_img[n2[0],n2[1]] == 1):
                cur = n2
            elif(n3 != last_visited and graph_img[n3[0],n3[1]] == 1):
                cur = n3
            elif(n4 != last_visited and graph_img[n4[0],n4[1]] == 1):
                cur = n4
            else:
                break;
            last_visited = temp

plt.figure()
plt.imshow(skel_img, cmap='Greys')
plt.scatter(*zip(*nodes), color='red')
plt.show()

