
adj_list = [[(1,4),(7,8)],
            [(0,4),(2,8),(7,11)],
            [(1,8),(3,7),(8,2),(5,4)],
            [(2,7),(4,9),(5,14)],
            [(3,9),(5,10)],
            [(2,4),(3,14),(4,10),(6,2)],
            [(5,2),(7,1),(8,6)],
            [(0,8),(1,11),(6,1),(8,7)],
			[(2,2),(6,6),(7,7)]]

def gen_adj_list_coe():
    "memory_initialization_radix=2;\nmemory_initialization_vector="
    adj_list_contents = "memory_initialization_radix=2;\nmemory_initialization_vector=\n" + \
                        '{:064b}'.format(0) + ",\n" #fill 0th row with zeros. Dummy node
    for i in range(len(adj_list)):
        adj_list_row = ""
        
        for (j, w) in adj_list[i]:
            n = j + 1
            adj_list_row += '{:010b}'.format(n) + '{:06b}'.format(w)
            print(n, w)

        if(i == len(adj_list) - 1):
            adj_list_contents += 16 * (4 - len(adj_list[i])) * "0" + adj_list_row + ";\n"
        else:
            adj_list_contents += 16 * (4 - len(adj_list[i])) * "0" + adj_list_row + ",\n"
        
    with open("adj_list.coe", 'w') as f:
        f.write(adj_list_contents)
    return None

gen_adj_list_coe()

"""
#Non-Negative Edge Weights
#O((V+E)log(V)) using binary heap
def dijkstra(A, w, s):
    d = [float(’inf’) for _ in A]           # shortest path estimates d_s
    parent = [None for _ in A]              # initialize parent pointers
    d[s], parent[s] = 0, s                  # initialize source
    Q = PriorityQueue()                     # initialize empty priority queue
    for v in range(len(A)):                 # loop through vertices
        Q.insert(v, d[v])                   # insert vertex-estimate pair
    for _ in range(len(A)):                 # main loop
        u = Q.extract_min()                 # extract vertex with min estimate
        for v in A[u]:                      # loop through out-going edges
            relax(A, w, d, parent, u, v)    # relax!
            Q.decrease_key(v, d[v])         # update key of vertex
    return d, parent
"""
