SZ_PredictionApp Executable

1. Prerequisites for Deployment 

Verify that MATLAB Runtime(R2024b) is installed.   
If not, you can run the MATLAB Runtime installer.
To find its location, enter
  
    >>mcrinstaller
      
at the MATLAB prompt.
NOTE: You will need administrator rights to run the MATLAB Runtime installer. 

Alternatively, download and install the Windows version of the MATLAB Runtime for R2024b 
from the following link on the MathWorks website:

    https://www.mathworks.com/products/compiler/mcr/index.html
   
For more information about the MATLAB Runtime and the MATLAB Runtime installer, see 
"Distribute Applications" in the MATLAB Compiler documentation  
in the MathWorks Documentation Center.

2. Files to Deploy and Package

Files to Package for Standalone 
================================
-SZ_PredictionApp.exe
-MCRInstaller.exe 
    Note: if end users are unable to download the MATLAB Runtime using the
    instructions in the previous section, include it when building your 
    component by clicking the "Runtime included in package" link in the
    Deployment Tool.
-This readme file 



3. Definitions

For information on deployment terminology, go to
https://www.mathworks.com/help and select MATLAB Compiler >
Getting Started > About Application Deployment >
Deployment Product Terms in the MathWorks Documentation



4. Once installed, open the application.

5. Enter the number of channels (e.g., 16).

6. Enter the sampling rate (e.g., 128 Hz).

7. Select the EEG file in .csv format.

8. Click Start Prediction to begin the analysis.

9. The predicted results will be displayed in the Class Probabilities and Classes sections.

10. The computation time will be shown in the Runtime section.
Center.




