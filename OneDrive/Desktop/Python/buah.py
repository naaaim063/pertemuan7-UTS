# DATA: [bulan, penjualan]
data = [
    [1, 100],
    [2, 120],
    [3, 110],
    [4, 130],
    [5, 150],
    [6, 500],
    [7, 550],
    [8, 530],
    [9, 200],
    [10, 180],
    [11, 170],
    [12, 190]
]

centroid1 = [2, 120]   
centroid2 = [7, 520]   

def jarak(a, b):
    return abs(a[1] - b[1])  

cluster1 = []
cluster2 = []

for d in data:
    if jarak(d, centroid1) < jarak(d, centroid2):
        cluster1.append(d)
    else:
        cluster2.append(d)

print("CLUSTER RENDAH ")
for c in cluster1:
    print(c)

print("\nCLUSTER TINGGI")
for c in cluster2:
    print(c)

# 🧠 interpretasi
print("\nINTERPRETASI")
print("Cluster 1 = MUSIM HUJAN / PENJUALAN RENDAH")
print("Cluster 2 = MUSIM PANAS / PENJUALAN TINGGI")