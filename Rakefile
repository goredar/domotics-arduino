require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
end

desc "Run tests"
task :default => :test

PATCH = 2
MINOR = 1
MAJOR = 0

desc "Commit patch and release gem"
task :patch do
  update { |sv,i| i == PATCH ? sv.succ : sv }
end

def update
  # Update version
  File.open "lib/domotics/arduino/version.rb", "r+" do |f|
    up = f.read.sub(/\d+.\d+.\d+/){ |ver| ver.split('.').map.with_index{ |sv, i| yield sv,i }.join('.') }
    f.seek 0
    f.write up
  end
  # add new files to repo
  %x(git add --all .)
  # commit
  %x(git commit -a --reuse-message=HEAD) =~ /nothing to commit/
  # release
  Rake::Task[:release].reenable
  Rake::Task[:release].invoke
end