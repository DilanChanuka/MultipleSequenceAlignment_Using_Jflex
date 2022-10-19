# MultipleSequenceAlignment_Using_Jflex
This project is created to test the applicability of Jflex with multiple sequence alignment problems.

You can use DNA,RNA or Protein sequences to identify the multiple sequence alignemnt results.

Required Commands:

  jflex .\alignment_final.jflex   (To compile the jflex file)
  
  javac .\AlignmentTool.java  (To compile the generated java file)
  
  java AlignmentTool input_R_1.txt (To run the java class, first argument -> class name, second argument -> input file)
  
  java AlignmentTool input_P_1.txt 
  
  java AlignmentTool input_D_1.txt
  
  java AlignmentTool input_D_2.txt  
  
  java AlignmentTool input_R_2.txt

  java AlignmentTool input_R_3.txt


** Apart from those examples, you can use any DNA, RNA or Protein sequence list as the input file **
