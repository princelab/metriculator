FactoryGirl.define do
  factory :msrun do
    raw_id "123456"
    group "humans"
    user { Factory.next :username }
  end

  factory :metric do
    metric_input_file "tfiles/test3__1.txt"
    association :msrun
  end

  sequence :username do |n|
    names = %w[ James Joe John ]
    "#{names[rand 3]}_#{n}"
  end
  
  sequence :alert_description do |n|
    descriptions = %w{ chromatography ion_source ion_treatment }
    "#{descriptions[rand 3]}_#{n}"
  end

  sequence :true_false do |n|
    opts = [true, false]
    "#{opts[rand 2]}"
  end

  factory :alert do 
    show {Factory.next :true_false}
    email {Factory.next :true_false}
    description {Factory.next :alert_description}
    created_at DateTime.now
  end
end
