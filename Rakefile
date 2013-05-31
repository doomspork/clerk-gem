require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/test*.rb', 'test/**/test*.rb']
end

desc "Run tests"
task :default => :test

task :coverage => [:coverage_env, :test]
task :coverage_env do
  ENV['COVERAGE'] = '1'
end
