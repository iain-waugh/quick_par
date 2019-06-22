# Quick Synthesis / Place and Route

### What is this?

This is a quick way to test HDL ideas out and see how they synthesise into digital logic.

Use it to see the logic that you will get if you write code in a certain way.



### Setup:

Make sure Vivado is installed and on your executable path.  You should be able to type Vivado from the command line to open the GUI.



### Usage:

Create a VHDL file in the `src` directory and give it the same filename as the entity.

Then, `cd` to `syn/vivado` and type:

`PROJECT  = <your entity name> make`

This gives you a build directory under `syn/vivado/build_your_project` which you can examine by opening the '.dcp' file.



For speed, you can just get the synthesised '.dcp' file by typ:

`PROJECT  = <your entity name> make synth`

