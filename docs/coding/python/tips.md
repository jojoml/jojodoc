## Some python tips

### pip install using other cache dir
https://github.com/pypa/pip/issues/5816
```
TMPDIR=/data/vincents/ pip install --cache-dir=/data/vincents/ --build /data/vincents/ tensorflow-gpu
```


### Tips for passing reference in python
**Python's variable are generally different than that in other languages**, see below figure for a straightforward illustration.

![s](https://i.stack.imgur.com/FdaCu.png)

see https://stackoverflow.com/questions/986006/how-do-i-pass-a-variable-by-reference for more info.


## Useful debugging tools
IPDB
https://pypi.org/project/ipdb/

## Deploy your code to server
Vscode Deploy Plugin