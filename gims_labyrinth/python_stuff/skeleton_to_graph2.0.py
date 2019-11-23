import numpy as np
from collections import deque
import imageio
import matplotlib.pyplot as plt

skel_img = (imageio.imread("test_imgs/skel_chain.png") > 0).astype(int)

cur = (1,1)

avg = 0
count = 0
positions = deque()
node_pos = []
MAX_POS_SIZE = 30
last_theta = 180
penultimate_theta = 180
drought_counter = 0
delay = 0
visited = set()
while(True):
    positions.append(cur)
    visited.add(cur)
    if(len(positions) > MAX_POS_SIZE + 1):
        positions.popleft()
        v1 = np.array([positions[0][0], positions[0][1]]) - np.array([positions[MAX_POS_SIZE//2][0], positions[MAX_POS_SIZE//2][1]])
        v2 = np.array([positions[MAX_POS_SIZE][0], positions[MAX_POS_SIZE][1]]) - np.array([positions[MAX_POS_SIZE//2][0], positions[MAX_POS_SIZE//2][1]])
        cos_theta = np.dot(v1, v2)/(np.linalg.norm(v1) * np.linalg.norm(v2))
        theta = np.arccos(cos_theta) * 180/np.pi
        delay = max(delay - 1, 0)
        print(theta)
        if(theta < 150):
            if(penultimate_theta > last_theta and last_theta < theta and delay == 0):
                node_pos.append([positions[MAX_POS_SIZE//2 - 1][0], positions[MAX_POS_SIZE//2 - 1][1]])
                print("NODE ADDED")
                delay = 10
            else:
                drought_counter += 1
            penultimate_theta = last_theta
            last_theta = theta
    #left
    if(skel_img[cur[1] , cur[0] - 1] == 1 and (cur[0] - 1, cur[1]) not in visited):
        cur = (cur[0] - 1, cur[1])
    #right
    elif(skel_img[cur[1], cur[0] + 1] == 1 and (cur[0] + 1, cur[1]) not in visited):
        cur = (cur[0] + 1, cur[1])
    #up
    elif(skel_img[cur[1] - 1, cur[0]] == 1 and (cur[0], cur[1] - 1) not in visited):
        cur = (cur[0], cur[1] - 1)
    #down
    elif(skel_img[cur[1] + 1, cur[0]] == 1 and (cur[0], cur[1] + 1) not in visited):
        cur = (cur[0], cur[1] + 1)
    else:
        break;

node_pos = np.array(node_pos)
plt.figure()
plt.imshow(skel_img, cmap='Greys')
plt.scatter(node_pos[:,0], node_pos[:,1], color='red')
plt.show()

'''
skel_img = (imageio.imread("test_imgs/skel_chain.png") > 0).astype(int)

cur = (1,1)

avg = 0
count = 0
positions = deque()
node_pos = []
MAX_POS_SIZE = 30
last_theta = 180
penultimate_theta = 180
drought_counter = 0
visited = set()
while(True):
    positions.append(cur)
    visited.add(cur)
    if(len(positions) > MAX_POS_SIZE + 1):
        positions.popleft()
        v1 = np.array([positions[0][0], positions[0][1]]) - np.array([positions[MAX_POS_SIZE//2][0], positions[MAX_POS_SIZE//2][1]])
        v2 = np.array([positions[MAX_POS_SIZE][0], positions[MAX_POS_SIZE][1]]) - np.array([positions[MAX_POS_SIZE//2][0], positions[MAX_POS_SIZE//2][1]])
        cos_theta = np.dot(v1, v2)/(np.linalg.norm(v1) * np.linalg.norm(v2))
        theta = np.arccos(cos_theta) * 180/np.pi
        print(theta)
        if(theta < 150):
            
            if(penultimate_theta > last_theta and last_theta < theta):
                node_pos.append([positions[MAX_POS_SIZE//2 - 1][0], positions[MAX_POS_SIZE//2 - 1][1]])
                print("BOOOOOOOOOYA")
            else:
                drought_counter += 1
            penultimate_theta = last_theta
            last_theta = theta
    #left
    if(skel_img[cur[1] , cur[0] - 1] == 1 and (cur[0] - 1, cur[1]) not in visited):
        cur = (cur[0] - 1, cur[1])
    #right
    elif(skel_img[cur[1], cur[0] + 1] == 1 and (cur[0] + 1, cur[1]) not in visited):
        cur = (cur[0] + 1, cur[1])
    #up
    elif(skel_img[cur[1] - 1, cur[0]] == 1 and (cur[0], cur[1] - 1) not in visited):
        cur = (cur[0], cur[1] - 1)
    #down
    elif(skel_img[cur[1] + 1, cur[0]] == 1 and (cur[0], cur[1] + 1) not in visited):
        cur = (cur[0], cur[1] + 1)
    else:
        break;

node_pos = np.array(node_pos)
plt.figure()
plt.imshow(skel_img, cmap='Greys')
plt.scatter(node_pos[:,0], node_pos[:,1], color='red')
plt.show()
'''
