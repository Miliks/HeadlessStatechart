# HeadlessStatechart
test repo for headless code generation
1. Unpack hyvar archive and copy it together with Dcoker and input_13.json into the folder where docker will be executed.
2. Copy yakindu-sctpro folder into the same folder.
3. Run: $ docker build -t hyvar_rene .
4. Run: $  docker run -p 8090:8080 --name hyvar_rene --entrypoint="/bin/bash" --rm -t -i hyvar_rene
5. Run: $ jolie hyvar_statechart_receiver.ol
6. in other shell go to the folder where input_13.json is located and run: curl -H "Accept:application/json" -H "Content-Type:application/json" -d @input_13.json   http://0.0.0.0:8090/receiveTUB
It should tickle the jolie service listening for the json message.
It should recieve message and extract the conent into the eCall.sct into the model folder inside of the sesorE project. After this the invoke_logic.sh would try to run the scc on this project.
It fails with the following message:
/home/hyvar/work/0.211533065055712Compile
Launching /home/yakindu-sctpro/SCT...
SCT:
The SCT executable launcher was unable to locate its
companion shared library.
Headless code generation done...
Code generation output....

stdError: SCT: Cannot open display:

