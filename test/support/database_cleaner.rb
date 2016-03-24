require 'database_cleaner'

DatabaseCleaner.orm = :mongoid
DatabaseCleaner.strategy = :truncation

class MiniTest::Spec
  around do |tests|
    DatabaseCleaner.cleaning(&tests)
  end
end
