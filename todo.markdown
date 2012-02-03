#This file is a running list of things to accomplish to finish the project

##TODO list (111102)

###Archiver
-	Test the metric starting
* Message Passing # TEST IT and the accompanying metric starting...

###Website
  - Tracking of what metric comparisons are already produced and available for viewing (Ensure they can't be recreated)
    - Prevent the same comparison from being created multiple times?
      - How can this be done??
  - Add breadcrumbs for graph heirarchy?
      -- might be had by the simple "up" link I've added.
  - Make a special viewing page for any graphs that are significantly different (T-test) __????  Would this really help???__
    * Or a page of links to the images?
  * http://www.datatables.net/ ????  Would this make that table easier?

###Database

###Tests
* Why is the integration test stufff not working? MetricsController,
  MsrunsController.





#Finished
* Convert the Knowntrends hash to one more like the QC defaults one... where each object can be set individually
* Implement database updating of locations and the file moving system
* Message clearing fxns so that I can clean out the lists... maybe monthly?
- Fix the ordering for the graphs... why aren't graphs working on ValidusArmo?
- Metrics#show tables
- Build a error catcher for this problem: 
    Rserve: no process found
    Fatal error: you must specify '--save', '--no-save' or '--vanilla'
  * It should use "R CMD BATCH r\_rserve\_save.R" to fix it, I think.
- Fix the comparisons graph redirect error
- Add searchable fields to the comparisons list
- Add a yaml app\_config and QC\_config edit page into the website?
    - This would help make it easier to configure for people... right?
- Fix deletions of comparisons
- A build or install function that allows for automated installation with "gets" statements to ask the questions?


#Unnecessary upon further considerations
- figure out how to AJAX update the alerts page  
