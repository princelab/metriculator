#This file is a running list of things to accomplish to finish the project

##TODO list (111102)

###Archiver
- Provide a legend and two fields for the description of the datasets, use them at the top of each page to define the datasets.
-	Test the metric starting
- Add a yaml app_config and QC_config edit page into the website?
    - This would help make it easier to configure for people... right?
*	Message Passing # TEST IT and the accompanying metric starting...
* Implement database updating of locations and the file moving system
* Error handling modes for all the issues that missing files can produce. (I miss files if Xcalibur mode isn't the way the files are being input... so to handle acquiring previous data... I need error handling)
* Create a generator for the \*.bat script used for calling archiver from xcalibur.  Motivation?  Automate the setting of the log location from the app\_config.  

###Website
  - Tracking of what metric comparisons are already produced and available for viewing (Ensure they can't be recreated)
    - Prevent the same comparison from being created multiple times?
      - How can this be done??
  - Add breadcrumbs for graph heirarchy?
      -- might be had by the simple "up" link I've added.
  - figure out how to AJAX update the alerts page  
  - Make a special viewing page for any graphs that are significantly different (T-test) __????  Would this really help???__
    * Or a page of links to the images?
  * http://www.datatables.net/ ????  Would this make that table easier?

###Database

###Tests
* Why is the integration test stufff not working? MetricsController,
  MsrunsController.





#Finished
* Message clearing fxns so that I can clean out the lists... monthly
* Convert the Knowntrends hash to one more like the QC defaults one... where each object can be set individually
