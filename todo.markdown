#This file is a running list of things to accomplish to finish the project

##TODO list (110805)

###Archiver
-	Metric starter fxnality  # TEST THIS!!
*	Message Passing # Mostly done, just clean it up!
* Cron fxnality can be had by the rufus-scheduler gem, which implements cron stuff in ruby.  Looks pretty easy to use.  
		`scheduler = Rufus::Scheduler::PlainScheduler.start_new(:thread_name => 'my scheduler')`
* EMAIL SMTP ROUTING or I can't test my own email system.
* Use pony gem for email

###Website
  - Tracking of what metric comparisons are already produced and available for viewing (Ensure they can't be recreated)
    - Prevent the same comparison from being created multiple times?
  - Add breadcrumbs for graph heirarchy?
  - Pagination is pretty broken

###Database


###Tests
* Why is the integration test stufff not working? MetricsController,
  MsrunsController.
