The Task folder contains the Kinarm Approach Avoid Task, Kinarm Approach Avoid Task model, the .dtp file for this task, all 24 active/sedentary/circle/square images, and instruction images to show images.

The ReadC3D folder contains matlab scripts developed by Kinarm for analysing .kinarm and .c3d files.

The Analysis folder contains the matlab scripts to analysize the Kinarm Approach Avoid Task. The scripts required to run analysis of the KAAT are the extractApproachAvoidTask.m and groupData.m files. These script calls on other functions (find... series) to calculate parameters.
First run the extractApproachAvoidTask.m to convert .kinarm files into matlab data and excel data then run groupData.m to summarize participants data and output a master list of parameters as an excel file.
