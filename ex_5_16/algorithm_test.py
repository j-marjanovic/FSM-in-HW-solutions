# -*- coding: utf-8 -*-
"""
 Plot of function sqrt(x**2 + y**2) and its approximation 
 max(a-a/8+b/2, a) where a = max(x, y) and b = min(x, y)
 
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm

def f1(x, y):
    ''' Original function '''
    
    return np.sqrt(x**2 + y**2)


def f2(x, y):
    ''' Aproximation '''
    
    if x.shape != y.shape:
        raise ValueError("operands could not be broadcast together with " \
                          "shapes {} and {}.".format(x.shape, y.shape))

    _shape = x.shape

    x = x.flatten()
    y = y.flatten()

    a = np.maximum(x, y)
    b = np.minimum(x, y)

    return np.maximum(a-a/8+b/2, a).reshape(_shape)


X = np.arange(0, 10, 1)
Y = np.arange(0, 10, 1)
X, Y = np.meshgrid(X, Y)

Z1 = f1(X, Y)
Z2 = f2(X, Y)

fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')
ax.set_xlabel('X')
ax.set_ylabel('Y')
ax.set_zlabel('f(X,Y)')


#pylint: disable=no-member
surf1 = ax.plot_surface(X, Y, Z1,
                        rstride=1, cstride=1,
                        cmap=cm.jet,
                        linewidth=1,
                        antialiased=True,
                        alpha=0.5)

surf2 = ax.scatter(X, Y, Z2)


fig.savefig('funcs_diff.png')
