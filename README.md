# tclrules

A project I made to see what I can make within a couple of days in TCL and I was pleasantly surprised. I have created a small task runner that checks whether there are cycles or that steps are unimplemented. 

## Usage 

   rule <name-of-rule> {<other-rules>...} {
        tclCommand |
        run <shelCommand>
   } (<once|mult>)?


## Example

   rule test {test2} {
        run echo test
   }



