FactoryBot.define do
  factory :node do
    label { "Node-#{Time.now.to_i}" }
    parent_id { nil }

    trait :with_project do
    end

    trait :with_properties do
      properties {
        {
          'network': 'blue',
          'ip': [
            '1.1.1.1',
            '1.1.1.2',
          ],
          'services': [
            {
              'port': 123,
              'protocol': 'udp',
              'state': 'open',
              'name': 'NTP'
            },
            {
              'port': 161,
              'protocol': 'udp',
              'state': 'open',
              'name': 'NTP'
            }
          ],
          'services_extras': {
            'udp/123': [
              {
                'source': 'nessus',
                'id': 'some id',
                'output': 'a message'
              }
            ]
          }
        }
      }
    end
  end
end
