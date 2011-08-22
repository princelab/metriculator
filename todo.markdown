#This file is a running list of things to accomplish to finish the project

##TODO list (110805)

###Archiver
-	Metric starter fxnality
*	Message Passing
* Cron fxnality can be had by the rufus-scheduler gem, which implements cron stuff in ruby.  Looks pretty easy to use.  
		`scheduler = Rufus::Scheduler::PlainScheduler.start_new(:thread_name => 'my scheduler')`
* EMAIL SMTP ROUTING or I can't test my own email system.
* Add calculator for the variance in each sample, in comparison to the previous filter results
* Variance comparison to alert settings, generation of alerts
* Appconfig level admin email setting
* Use pony gem for email
* GreenThread
* config needs to have a metric\_instrument\_type

###Website
  - Server filter AJAX selection list with an Array of desired filterable attributes
  - Tracking of what metric comparisons are already produced and available for viewing (Ensure they can't be recreated)
  - Show the graphs
    - Add breadcrumbs for graph heirarchy?
    - When to set the symlink? And do we always assume that they are
      symlinked into the public/ directory?
  - Alerts should only show up in views if they are marked to show.
  - Add support for Alerts which autohide?
  - Deleting alerts shown on the web page should only make them not be
    shown, not actually delete them. In case they are to be emailed as
    well.
  - Pagination is pretty broken

###Database


###Tests
* Why is the integration test stufff not working? MetricsController,
  MsrunsController.
