A tool for optimizing the positioning of different elements.

Currently using Godot 4.2

TODO :
- Remove link functionality
- Split Auto functionality (Currently splits at random)
- Split with angle decided by user
- Add a 3D mode
- A panel to config the created nodes
- A panel for node categories, with common values, shared at creation and modified simultanously

BUG :
- when creating a node while in pause, the node is not affected by the pause state.
- When tapping the shortcuts for a Ctrl+Key action, the <Key> action is executed as well as the CTRL action.

Default shortcuts (QWERTY configuration) :
- W/S : Attraction/repulsion up/down
- E : Create node
- R : Remove node
- D : Duplicate node
- S : Split node
- F : fix node
- Ctrl+R : Reset simulation
- Ctrl+T : Generate random nodes
- \<Space> : pause simulation
- Ctrl+S : Save simulation
- Ctrl+O : Load simulation
