require 'rake/testtask'

Rake::TestTask.new('test') do |t|
  t.libs.push "test"
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

