#This file is a running list of things to accomplish to finish the project

##TODO list (110805)

###Archiver
-	Metric starter fxnality
*	Message Passing
* Cron fxnality can be had by the rufus-scheduler gem, which implements cron stuff in ruby.  Looks pretty easy to use.  
		`scheduler = Rufus::Scheduler::PlainScheduler.start_new(:thread_name => 'my scheduler')`
* Add calculator for the variance in each sample, in comparison to the previous filter results
* Variance comparison to alert settings, generation of alerts
* Appconfig level admin email setting
* Use pony gem for email
* GreenThread

###Website
  - Server filter AJAX selection list with an Array of desired filterable attributes
  - Tracking of what metric comparisons are already produced and available for viewing (Ensure they can't be recreated)
  - Show the graphs
  - Alerts in header and view page
    - Add jQuery to hide deleted alert
  - Fix pagination when there is only one page

###Database
