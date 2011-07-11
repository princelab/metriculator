FactoryGirl.define do
  factory :msrun do
    raw_id "123456"
    group "humans"
    user { Factory.next :username }
  end

  factory :metric do
    metric_input_file "tfiles/metrics/test1.txt"
    association :msrun
  end

  sequence :username do |n|
    names = %w[ James Joe John ]
    "#{names[rand 3]}_#{n}"
  end
end
