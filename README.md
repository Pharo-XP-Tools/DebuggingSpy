# DebuggingSpy
A tool to spy on debugging actions for research experiments.


[![Tests](https://github.com/StevenCostiou/DebuggingSpy/actions/workflows/dsspy.yaml/badge.svg)](https://github.com/StevenCostiou/DebuggingSpy/actions/workflows/dsspy.yaml)

```Smalltalk
Metacello new
    baseline: 'DebuggingSpy';
    repository: 'github://StevenCostiou/DebuggingSpy:P12';
    load.
```

To cite the use of this tool, please use: https://hal.science/hal-04858378v1

```bib
@softwareversion{costiou:hal-04858378v1,
  TITLE = {{Debugging Spy}},
  AUTHOR = {Costiou, Steven and Van{\`e}gue, Adrien},
  URL = {https://inria.hal.science/hal-04858378},
  NOTE = {},
  INSTITUTION = {{Centre Inria de l'Universit{\'e} de Lille}},
  YEAR = {2024},
  MONTH = Dec,
  SWHID = {swh:1:dir:0f63d67301c0ad3174d17c89a13b52e595837877;origin=https://github.com/Pharo-XP-Tools/DebuggingSpy;visit=swh:1:snp:ae7703ee9ee6f77eb10697b7d9fdf90678a768a0;anchor=swh:1:rev:fbec9a14cbdaa478f498196c0f993062441ef3ae},
  VERSION = {1.0},
  REPOSITORY = {https://github.com/Pharo-XP-Tools/DebuggingSpy},
  LICENSE = {MIT License},
  KEYWORDS = {Debug ; Software instrumentation},
  HAL_ID = {hal-04858378},
  HAL_VERSION = {v1},
}
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


# User documentation
## Log data to local file

Load the P12 baseline into a Pharo 12 image, then execute the following line:
```Smalltalk
DSSpyInstrumenter instrumentSystem
```
After that, the system starts logging.
Logs are serialized in the image working directory, in the *ds-spy* folder:

<img width="445" alt="Capture d’écran 2025-03-09 à 22 45 10" src="https://github.com/user-attachments/assets/c0f7595b-6d32-4101-b6c2-45f54c5fddd0" />


## Log data to a remote server

## Read logged data
### Materialize log history
### Build visualizations
