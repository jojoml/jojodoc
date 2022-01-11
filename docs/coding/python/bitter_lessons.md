## Reason not to use [x]*y
```python
x = [[0]*3] * 3
print(x)
x[1][1] = 1
print(x)
```
gives:
```
[[0, 0, 0], [0, 0, 0], [0, 0, 0]]
[[0, 1, 0], [0, 1, 0], [0, 1, 0]]
```
Correct way to do it:
```
x = [[0]*3 for i in range(3)]
print(x) 
x[1][1] = 1
print(x)
```
