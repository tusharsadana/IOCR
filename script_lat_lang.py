import pandas as pd

dataset = pd.read_csv('out.csv')

X = dataset.values
strReq = ''
for i in range(len(X)):
    strReq += 'new google.maps.LatLng('+str(X[i][0])+','+str(X[i][1])+'),'
print(strReq)
