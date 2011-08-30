# The default settings for new alerts
Alert_defaults = { email: true, show: true }
# This is a class which will facilitate the generation of Alerts and the automation of sending out alert emails.
class Alerter
  class << self
    require 'pony'
# This fxn will add an alert to the database
# @param [String] [Hash]  Takes a message string, and also accepts Hash keys which will modify the default behavior as defined in the Alert_defaults constant {Alert_defaults}
    def create(string, opts = {})
      @@opts = Alert_defaults.merge(opts)
      if @@opts != Alert_defaults
        options = @@opts.to_s.gsub(/\{|\}/, '')
        Alert.create({:description => string}.merge(options))
      else
        Alert.create(:description => string)
      end
    end
# This fxn will delete the specified entry in the database
# @param [Integer] a number which represents the id for the Alert to be destroyed
    def delete(num)
      Alert.get(num).destroy
    end
# This fxn will use the "Pony" gem to send out an alert email to the specified address.  This fxn will include all the alert text for every entry in the database for which the email column has a true value.  Once the email is sent, that collection of DB Alerts will have the email column altered to ensure each alert is only sent once.
    def send_email(email_address, subject = "Generic QC Alerts", admin_email = "Administrator@YourLocalMetricSite.changethis")
      body_text = "Attn:  According to the filter settings you've configured, we found the following alerts while running on ## FILE NAME? ##"
      to_send = Alert.all(:email => true)
      to_send.each do |alert|
        body_text << format_alert_for_email(alert)
      end
      body_text << "For more information, visit the ## WEBADDRESS ## "
# Send the email
      Pony.mail(to: email_address, from: admin_email, subject: subject, :body => body_text)
      to_send.update(:email => false)
    end
# This function controls the output format for the alert message.
# @param [Alert] Alert class
# @return Nothing
    def format_alert_for_email(alert)
      "At #{alert.created_at} we found #{alert.description}"
    end
  end # class << self
end # Alert
