# encoding: utf-8
# rubocop:disable Style/ClassAndModuleChildren,
require 'logstash/namespace'
require 'logstash/inputs/base'
require 'stud/interval'
require 'rubygems'
require 'git'

# Logstash input plugin for getting commits from Git repository
class LogStash::Inputs::GitRepo < LogStash::Inputs::Base
  config_name 'gitrepo'

  milestone 1
  # This is the name to call inside the input configuration block for the
  # plugin:
  #
  #   input {
  #     git {...}
  #   }

  default :codec, 'json'

  # The configuration, or config section allows you to define as many
  # parameters as are needed to enable Logstash to process events.
  # There are several configuration attributes:
  #
  # :validate - allows you to enforce passing a particular data type to
  #   Logstash for this configuration option.
  # :default - lets you specify a default value for a parameter
  # :required - whether or not this parameter is mandatory (Boolean)
  # :deprecated - informational (also a Boolean true or false)

  # Git repository to collect statistics from
  config :repository,
         validate: :string,
         required: true,
         default: 'https://github.com/git/git'

  config :branch,
         validate: :string,
         required: true,
         default: 'master'
  # Git repository name to use
  config :name,
         validate: :string,
         required: true,
         default: 'git'
  # Interval time (in seconds) between update check Git for changes
  config :interval,
         validate: :number,
         default: 5

  # Logstash inputs must implement two main methods: register and run.
  # 'public' means the method can be called anywhere, not just within the class.
  # This is the default behavior for methods in Ruby, but it is specified
  # explicitly here anyway.

  # The Logstash register method is like an initialize method.

  public

  def register
    git_clone(@repository)
    @last_check = 0
  end # def register

  public

  def run(queue)
    Stud.interval(@interval) do
      begin
        time = Time.now
        @git.pull
        add_commits(queue, @last_check, time)
        @last_check = time
      rescue LogStash::ShutdownSignal
        return
      end
    end
  end # def run

  private

  def git_clone(repository)
    @logger.info("Cloning Git repository from #{repository} on branch " \
      "#{branch} at /tmp/#{@name}_#{@branch}")
    @git = Git.clone(@repository, @name, path: "/tmp/#{@name}_#{@branch}")
    @git.fetch
    @git.checkout(@branch)
  end

  private

  def add_commits(queue, from_date, to_date)
    @git.log.since(from_date).until(to_date).each do |commit|
      commit_hash = commit2hash(commit)
      create_event(queue, commit_hash)
    end
  end

  private

  def commit2hash(commit)
    { '@timestamp' => commit.author_date,
      'repository' => @repository,
      'message' => commit.message,
      'author' => add_author(commit.author),
      'committer' => add_committer(commit.committer),
      'sha' => commit.sha,
      'statistics' => add_statistics(commit) }
  end

  private

  def add_committer(committer)
    {
      'name' => committer.name,
      'email' => committer.email,
      'date' => committer.date
    }
  end

  private

  def add_author(author)
    {
      'name' => author.name,
      'email' => author.email,
      'date' => author.date
    }
  end

  private

  def add_statistics(commit)
    {
      'insertions' => commit.diff_parent.insertions,
      'deletions' => commit.diff_parent.deletions,
      'lines' => commit.diff_parent.lines,
      'files' => commit.diff_parent.size
    }
  end

  private

  def create_event(queue, commit_hash)
    event = LogStash::Event.new(commit_hash)
    @logger.debug("Addind event: #{event}")
    decorate(event)
    queue << event
  end
end
