# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False
import array
import numpy as np
from libc.math cimport sqrt

def query_integral_image(unsigned int[:,:] integral_image, int size_x, int
                         size_y, random_state, double desired_x, double desired_y, double distance_threshold):
    cdef int x = integral_image.shape[0]
    cdef int y = integral_image.shape[1]
    cdef int area, i, j
    cdef int hits = 0

    # count how many possible locations
    for i in xrange(x - size_x):
        for j in xrange(y - size_y):
            area = integral_image[i, j] + integral_image[i + size_x, j + size_y]
            area -= integral_image[i + size_x, j] + integral_image[i, j + size_y]
            if not area:
                hits += 1
    if not hits:
        # no room left
        return None
    
    cdef double lowest_distance = float('inf')
    cdef int best_i, best_j = -1
    cdef double distance_to_desired = 0.0
    #hits = 0
    if desired_x >= 0 and desired_y >= 0:
        for i in xrange(0, x - size_x):
            for j in xrange(0, y - size_y):
                area = integral_image[i, j] + integral_image[i + size_x, j + size_y]
                area -= integral_image[i + size_x, j] + integral_image[i, j + size_y]
                if not area:
                    #hits += 1
                    distance_to_desired = (desired_x*x - i) ** 2 + (desired_y*y - j) ** 2
                    if distance_to_desired < lowest_distance:
                        lowest_distance = distance_to_desired
                        best_i = i
                        best_j = j
        #print("best_i: ", best_i, "best_j: ", best_j)
        if best_i >= 0 and best_j >= 0:
            if sqrt(lowest_distance) < distance_threshold:
                return best_i, best_j
            else:
                return None
    
    # else pick a location at random
    cdef int goal = random_state.randint(0, hits)
    hits = 0
    for i in xrange(x - size_x):
        for j in xrange(y - size_y):
            area = integral_image[i, j] + integral_image[i + size_x, j + size_y]
            area -= integral_image[i + size_x, j] + integral_image[i, j + size_y]
            if not area:
                hits += 1
                if hits == goal:
                    return i, j
