# MSI Cache Coherence Controller Toy

## Assignment Goals & Description
The goal of this lab is to primarily expose you to modeling FSMs both graphically and in RTL. We'll model a 'Coherence Controller' designed for a cache coherence protocol. ([https://en.wikipedia.org/wiki/Cache_coherence](https://en.wikipedia.org/wiki/Cache_coherence)). 

To provide some background, the coherence controller tells you whether a specific piece of data can be used, and is utilized in multicore CPUs. The specific cache coherence protocol we'll be modeling is known as 'MSI'. ([https://en.wikipedia.org/wiki/MSI_protocol](https://en.wikipedia.org/wiki/MSI_protocol))

Simply put, it makes sure that everyone is up-to-date on a piece of data (analogous to someone learning a piece of gossip, and then telling everyone about the new piece of data). 

Without a coherence controller, you wouldn't know if you're using old data (that has been now invalidated, as there is new gossip), using new data (you've just learned some new tea but haven't told anyone yet), or are up to date on the data (you learned the new gossip, shared it, and now everyone has the same tea).

Data can be referred to in any of these manners: 'clean' (you share the current up-to-date value of data), 'dirty' (you've modified the data, and no one else knows yet), or 'invalid' (your data is incorrect and old).

## Assignment Spec
**Outputs must appear in the same cycle that your input appears. State should update on the positive edge of the clock.**

Additionally, utilize ENUMs for state description; while we didn't discuss it, they're not hard to implement and will save you from having to use magic numbers. Clean code is key, especially for debugging!

### States
The MSI protocol refers to the states of your Coherence Controller FSM. There are three states:
- M (Modified)
- S (Shared)
- I (Invalid)

### Module Inputs
There will be six module inputs:
- `bus_read`
- `bus_write`
- `write`
- `read`
- `clk`
- `rst_n`

Bus inputs indicate that some other core has performed a read or write (they've learned the up-to-date gossip, or have gained some new gossip).
Read/write inputs indicate that you are performing a read or write (you're learning the up-to-date gossip, or have yourself learned new gossip).

We'll use asynchronous low reset; assume that on asynchronous reset (rst_n == 0), you set yourself to Invalid.
Inputs can be treated as synchronous 1-cycle pulses, sampled at positive clock edge.

### Module Outputs
There will be four module outputs:
- `issue_bus_rd`
- `issue_bus_rdx`
- `issue_bus_upgrade`
- `issue_bus_wb`

issue_bus_rd indicates that you are reading (gaining clean data/up-to-date gossip).
issue_bus_rdx indicates that you are writing (telling other people their data/gossip is now out-of-date, so they don't parrot invalid data).
issue_bus_wb indicates that you are writing back your dirty data (sharing your data with other cores or informing other people of the new tea).
issue_bus_upgrade indicates that you are writing to a piece of clean data you own (you have the up-to-date tea, but now learn something new).

Outputs are combinational functions of the current state and the current cycle’s input pulses.

### Transitions
Transitions between states are dependent on both the current state and the input (Mealy Machine). The transition conditions and I/O follow:

Invalid (I) State
- On read, go to Shared (S) State and set issue_bus_rd high.
- On write, go to Modified (M) State and set issue_bus_rdx high.

Shared (S) State
- On bus_write, go to Invalid (I) state (no outputs in this case, your data is clean so you don't have to do anything).
- On write, go to Modified (M) state and set issue_bus_upgrade high.

Modified (M) State
- On bus_read, go to Shared (S) state and set issue_bus_wb high.
- On bus_write, go to Invalid (I) state and set issue_bus_wb high.

For inputs not listed in transition (e.g. bus_read is high when core is in Invalid State), assume there's no state change and no outputs. 

### Additional Notes

You are allowed to assume only 1 input will be active at any time. 
Additionally, if no inputs are provided, retain the current state and set all outputs low. 
Outputs should be 1-cycle pulses, corresponding to the synchronous inputs - you should not have multiple outputs active at any given time, either only 1 high output or no outputs high.

## Submission

Submit a drawing of the FSM. Demonstrate state transitions, and on each transition line, show the input that caused the change (i.e., on the S -> I line, write bus write to indicate that on bus write, we transition from Shared to Invalid).

Submit your RTL code modeling the FSM. We will have our own testbench to verify your code, which will likely (?) be very simple and assertion based.

Lastly, submit your own testbench that you feel sufficiently verifies your FSM. Use whatever methods you feel are valid (assertions, random assertions, formal methods, etc.). Obviously, your code should pass your own testbench.
