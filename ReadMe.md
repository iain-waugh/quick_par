# Quick Synthesis / Place and Route

### What is this?

This is a quick way to test HDL ideas out and see how they synthesise into digital logic.

Use it to see the logic that you will get if you write code in a certain way.



### Setup:

Install Xilinx Vivado (if you haven't done so already).

Make sure Vivado is on your executable path.  You should be able to type `vivado` from the command line to open the GUI.

Install a GNU `make` tool from somewhere and make sure it's on your executable path.  You should be able to type `make` from the command line.



### Usage:

Create a VHDL file in the `src` directory and give it the same filename as the entity.

Then, `cd` to `syn/vivado` and type:

`PROJECT  = <your entity name> make`

Or `make PROJECT=<your entity name>` ; both options work.

This gives you a build directory under `syn/vivado/build_your_project` which you can examine by opening the '.dcp' file.

If you want to target a different part, specify it on the command line like this:

`make PROJECT=<your entity name> PART=<part number>`

Use the same part number that you see in Vivado's "New Project" wizard.

Example:

`make PROJECT=counters PART=xcku040-fbva676-2-e`

For speed, you can just get the synthesised '.dcp' file by typing:

`PROJECT  = <your entity name> make synth`

