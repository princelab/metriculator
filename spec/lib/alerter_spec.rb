require 'spec_helper'

describe 'class Alerter' do
  before :each do
    Alert.all.destroy
    @alert = Alert.create(:description => "testing this out")
  end
  it 'puts Alerts into the database' do  
    b = Alert.all(:description => "testing this out")
    b.size.should == 1
  end
  it 'deletes Alerts from the database' do 
    a = Alert.all(:description => "testing this out")
    p a.size
    @alert.destroy
    b = Alert.all(:description => "testing this out")
    b.size.should == 0
  end
  it 'formats alerts to send out in emails' do 
    txt = Alerter.format_alert_for_email(@alert)
    p txt
  end 
  it 'sends emails' do 
  end
end
