# DebuggingSpy
A tool to spy on debugging actions for research experiments.

[![Tests](https://github.com/StevenCostiou/DebuggingSpy/actions/workflows/dsspy.yaml/badge.svg)](https://github.com/StevenCostiou/DebuggingSpy/actions/workflows/dsspy.yaml)

```Smalltalk
Metacello new
    baseline: 'DebuggingSpy';
    repository: 'github://StevenCostiou/DebuggingSpy';
    load.
```

# Recorded events

| **Type of traces**         | **User activity/block event or action** | **Debugging action** | **Navigation/inspection action** | **Debugging event** | **Code edition action** |
|-----------------------------|------------------------------------------|-----------------------|-----------------------------------|---------------------|--------------------------|
| Breakpoint                 |                                          | x                     |                                   |                     |                          |
| Variable breakpoint        |                                          | x                     |                                   |                     |                          |
| Halt change                |                                          | x                     |                                   |                     |                          |
| Halt hit                   |                                          |                       |                                   | x                   |                          |
| Clipboard copy             |                                          |                       |                                   |                     | x                        |
| Clipboard paste            |                                          |                       |                                   |                     | x                        |
| Debug it                   | x                                        |                       |                                   |                     |                          |
| Do it                      | ?                                        |                       |                                   |                     |                          |
| Do it and go               | ?                                        |                       |                                   |                     |                          |
| Print it                   |                                          |                       | x                                 |                     |                          |
| Browse context             |                                          |                       | x                                 |                     |                          |
| Debugger action            |                                          | x                     |                                   |                     |                          |
| Debugger opening           | x                                        |                       |                                   |                     |                          |
| Full browse                |                                          |                       | x                                 |                     |                          |
| Inspect attribute          | x                                        |                       |                                   |                     |                          |
| Expand attribute           |                                          |                       | x                                 |                     |                          |
| Navigate attribute         |                                          |                       | x                                 |                     |                          |
| Inspect method             | x                                        |                       |                                   |                     |                          |
| Inspect method source      | x                                        |                       |                                   |                     |                          |
| Inspect object             | x                                        |                       |                                   |                     |                          |
| Select inspector page      |                                          |                       | x                                 |                     |                          |
| Logging error              |                                          |                       |                                   | x                   |                          |
| Method added               |                                          |                       |                                   |                     | x                        |
| Method modified            |                                          |                       |                                   |                     | x                        |
| Method removed             |                                          |                       |                                   |                     | x                        |
| Source code change         |                                          |                       |                                   |                     | x                        |
| Mouse down table           |                                          |                       | x                                 |                     |                          |
| Mouse enter table          |                                          |                       | x                                 |                     |                          |
| Mouse enter text editor    |                                          |                       | x                                 |                     |                          |
| Mouse enter window         | x                                        |                       |                                   |                     |                          |
| Mouse leave window         | x                                        |                       |                                   |                     |                          |
| Playground opened          | x                                        |                       |                                   |                     |                          |
| Playground read            |                                          |                       | x                                 |                     |                          |
| Playground write           |                                          |                       |                                   |                     | x                        |
| Query browse               |                                          |                       | x                                 |                     |                          |
| Start scrolling            |                                          |                       | x                                 |                     |                          |
| Stop scrolling             |                                          |                       | x                                 |                     |                          |
| Step                       |                                          | x                     |                                   |                     |                          |
| Window activated           | x                                        |                       |                                   |                     |                          |
| Window opened              | x                                        |                       |                                   |                     |                          |
| Window closed              | x                                        |                       |                                   |                     |                          |
| Proceed command            |                                          | x                     |                                   |                     |                          |
| Restart command            |                                          | x                     |                                   |                     |                          |
| Return value command       |                                          | x                     |                                   |                     |                          |
| Run to selection command   |                                          | x                     |                                   |                     |                          |
| Step into                  |                                          | x                     |                                   |                     |                          |
| Step over                  |                                          | x                     |                                   |                     |                          |
| Step through               |                                          | x                     |                                   |                     |                          |
