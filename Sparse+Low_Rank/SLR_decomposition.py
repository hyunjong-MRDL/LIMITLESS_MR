import os
import tifffile as tiff
import numpy as np
from scipy.linalg import svd

def forward_Casorati(directory):
    out_matrix = None
    for filename in os.listdir(directory):
        if ".tif" in filename:
            curr_img = tiff.imread(f"{directory}{filename}")
            flat_img = np.expand_dims(curr_img.transpose().flatten(), axis=1)
        if out_matrix is None:
            out_matrix = flat_img
        else:
            np.append(out_matrix, flat_img, axis=1)
    return out_matrix

def backward_Casorati(matrix):
    
    return

def L1_norm(matrix):
    return np.sum(np.abs(matrix))

def Frobenius_norm(matrix):
    return np.sum(np.square(matrix))

"""=====SVD algorithm=====

def eigen(matrix):
    # |A-lambda*I| = 0 특성방정식 풀이
    return

def SVD(matrix):
    LEFT_matrix = np.matmul(matrix, matrix.transpose())
    RIGHT_matrix = np.matmul(matrix.transpose(), matrix)
    L_eigvals, L_eigvecs = eigen(LEFT_matrix)
    R_eigvals, R_eigvecs = eigen(RIGHT_matrix)
    ncols = np.argsort(L_eigvals)[::-1]
    U = L_eigvecs[:, ncols]
    S = np.sqrt(L_eigvals)[::-1]
    Vt = R_eigvecs[:, ncols].transpose()
    return U, S, Vt

=====SVD algorithm (end)====="""

def Nuc_norm(matrix):
    _, S, _ = svd(matrix)
    return np.sum(S)

def soft_thresholding(X, tau):
    return np.sign(X) * np.maximum(np.abs(X - tau), 0)

def singular_value_thresholding(X, tau):
    U, Sigma, Vt = svd(X)
    Sigma = soft_thresholding(Sigma, tau)
    return U @ Sigma @ Vt

# Import data
root = "D:/Datasets/UCSD/"
path1 = f"{root}UCSDped1/"
path2 = f"{root}UCSDped2/"
trainfolder1 = [f"{path1}Train/{x}" for x in os.listdir(f"{path1}Train/") if "Train" in x]
trainfolder2 = [x for x in os.listdir(f"{path2}Train/") if "Train" in x]

original = forward_Casorati(trainfolder1[0])

# Initialization
Sparse, Low_rank, multiplier = np.zeros(original.shape), np.zeros(original.shape), np.zeros(original.shape)

objective = L1_norm(Sparse) + Nuc_norm(Low_rank) # minimize objective
constraints = Sparse + Low_rank - original # while satisfying constraints

# Lagrange multiplier
penalty = 0 # Initial value
augmented_lagrangian = objective + np.trace(multiplier.transpose() * constraints) + (penalty/2) * Frobenius_norm(constraints)

""" ADMM """
gamma, rho, max_iter = 1.0, 1.0, 100
tolerance = 1e-6
for i in range(max_iter):
    # (Step 1): Update sparse matrix
    Sparse = soft_thresholding(original - Low_rank + (1/rho) * multiplier, gamma/rho)

    # (Step 2): Update low-rank matrix
    Low_rank = singular_value_thresholding(original - Sparse + (1/rho) * multiplier, 1/rho)

    # (Step 3): Update multiplier
    multiplier = multiplier + rho * (Sparse + Low_rank - original)

    if ( Frobenius_norm(Sparse + Low_rank - original) / Frobenius_norm(original) ) < tolerance:
        break