Pipeline-ProMS performs cluster analysis on MS1 peaks based on given mzXML files and search-engine result-files 
in a given directory that contains the related files. To run it, please use the following command:

ProMS directory-name mspepsearch

or

ProMS directory-name omssa

or

ProMS directory-name spectrast



Please place ParametersForProMS.txt with the ProMS.exe in the same directory.


Currently, the produced raw.txt file name has no info about what search-engine-result file is used. 
But, the used search engine info is provided at the first line of each raw.txt file.



example:
ProMS C:\Studies\test\spectrast_xml spectrast
