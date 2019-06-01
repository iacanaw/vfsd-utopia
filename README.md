# vfsd-utopia
This project is adapted from the one in the book "SystemVerilog for Verification: A Guide to Learning the Testbench Language Features", by CHRIS SPEAR (Springer, 2012). Files were download from author's website (http://www.chris.spear.net/systemverilog/default.htm) and modified to run into Mentor's ModelSim tool (command line mode - not a project!). We intend to add instructions for guiding you through the compilation process in the future. File names were preserved, so copyright information can be tracked back to original files.

--------------------------------------------------------------------------------------------------------------------------------------

VFSD - Iaçanã

Para executar a verificação UVM:

No QuestaSim/ModelSim navegue para o diretório: \vfsd-utopia\scripts

Execute o comando: do 3_simul.do

Todos os módulos compilam. Porém o comportamento do Scoreboard não está adequado.
Apesar de receber os pacotes que o Driver envia para a interface Rx e os pacotes recebidos pelo Monitor pela interface Tx do Utopia, a verificação da corretude da transmissão não está funcionando adequadamente.