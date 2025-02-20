require 'bundler'
Bundler.setup

GEM_ROOT = File.expand_path('../../', __FILE__)
GEM_SPEC = "simple-cli.gemspec"

require 'simple/cli/version'
VERSION_FILE_PATH = 'lib/simple/cli/version.rb'

class VersionNumberTracker
  class << self
    def update_version_file(old_version_number, new_version_number)
      old_line = "VERSION = \"#{old_version_number}\""
      new_line = "VERSION = \"#{new_version_number}\""
      update = File.read(VERSION_FILE_PATH).gsub(old_line, new_line)
      File.open(VERSION_FILE_PATH, 'w') { |file| file.puts update }
      new_version_number
    end

    def auto_version_bump
      old_version_number = Simple::CLI::VERSION
      old = old_version_number.split('.')
      current = old[0..-2] << old[-1].next
      new_version_number = current.join('.')

      update_version_file(old_version_number, new_version_number)
    end

    def manual_version_bump
      update_version_file(Simple::CLI::VERSION, ENV['VERSION'])
    end

    def update_version_number
      @version = ENV['VERSION'] ? manual_version_bump : auto_version_bump
    end

    attr_reader :version
  end
end

namespace :release do
  task :version do
    VersionNumberTracker.update_version_number
  end

  task :build do
    Dir.chdir(GEM_ROOT) do
      sh("gem build #{GEM_SPEC}")
    end
  end

  desc "Commit changes"
  task :commit do
    Dir.chdir(GEM_ROOT) do
      version = VersionNumberTracker.version
      sh("git add #{VERSION_FILE_PATH}")
      sh("git commit -m \"bump to v#{version}\"")
      sh("git tag -a v#{version} -m \"Tag\"")
    end
  end

  desc "Push code and tags"
  task :push do
    sh('git push origin master')
    sh('git push --tags')
  end

  desc "Cleanup"
  task :clean do
    Dir.glob(File.join(GEM_ROOT, '*.gem')).each { |f| FileUtils.rm_rf(f) }
  end

  desc "Push Gem to gemfury"
  task :push_to_rubygems do
    Dir.chdir(GEM_ROOT) { sh("gem push #{Dir.glob('*.gem').first}") }
  end

  task default: [
    'version',
    'clean',
    'build',
    'commit',
    'push',
    'push_to_rubygems'
  ]
end

desc "Clean, build, commit and push"
task release: 'release:default'
