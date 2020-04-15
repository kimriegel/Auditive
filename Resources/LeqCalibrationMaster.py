import numpy as np
import math
import sys

from scipy.io import wavfile

fs, data = wavfile.read(sys.argv[1])
actual = 94 # known leq of sound for calibration

msq = 0
x = 1
i = 1
leqs = list()
rate = int(fs/10) #sample rate per .1 sec
tleq = 0
minrun = [1.0]
maxrun = [50000.0]

give = 0.1 # +/- amount of leq we are looking for
while tleq < (actual - give) or tleq > (actual + give): #calibrate the file
    tmsq = 0
    k = (max(minrun)+min(maxrun))/2
       
        #compute new leq with updated k
    for i in range (len(data)):
        tmsq = tmsq + (data[i][0]/k)**2
    tleq = 10*np.log10((tmsq/len(data))/(0.00002**2))
        #
    if tleq < (actual - give):
        maxrun.append(k)
    elif tleq > (actual + give):
        minrun.append(k)
    
    print ("k, tleq: ", k, tleq)
print ("tleq",tleq)
print ("k",k)
