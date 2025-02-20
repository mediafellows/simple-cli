# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/CyclomaticComplexity
# rubocop:disable Metrics/PerceivedComplexity

module Simple::CLI::Logger::ColoredLogger
  extend self

  attr_accessor :level

  COLORS = {
    clear:      "\e[0m",  # Embed in a String to clear all previous ANSI sequences.
    bold:       "\e[1m",  # The start of an ANSI bold sequence.
    black:      "\e[30m", # Set the terminal's foreground ANSI color to black.
    red:        "\e[31m", # Set the terminal's foreground ANSI color to red.
    green:      "\e[32m", # Set the terminal's foreground ANSI color to green.
    yellow:     "\e[33m", # Set the terminal's foreground ANSI color to yellow.
    blue:       "\e[34m", # Set the terminal's foreground ANSI color to blue.
    magenta:    "\e[35m", # Set the terminal's foreground ANSI color to magenta.
    cyan:       "\e[36m", # Set the terminal's foreground ANSI color to cyan.
    white:      "\e[37m", # Set the terminal's foreground ANSI color to white.

    on_black:   "\e[40m", # Set the terminal's background ANSI color to black.
    on_red:     "\e[41m", # Set the terminal's background ANSI color to red.
    on_green:   "\e[42m", # Set the terminal's background ANSI color to green.
    on_yellow:  "\e[43m", # Set the terminal's background ANSI color to yellow.
    on_blue:    "\e[44m", # Set the terminal's background ANSI color to blue.
    on_magenta: "\e[45m", # Set the terminal's background ANSI color to magenta.
    on_cyan:    "\e[46m", # Set the terminal's background ANSI color to cyan.
    on_white:   "\e[47m"  # Set the terminal's background ANSI color to white.
  }

  # rubocop:disable Style/ClassVars
  @@started_at = Time.now

  MESSAGE_COLOR = {
    info: :cyan,
    warn: :yellow,
    error: :red,
    success: :green,
  }

  def debug(*args, &block)
    log :debug, *args, &block
  end

  def info(*args, &block)
    log :info, *args, &block
  end

  def warn(*args, &block)
    log :warn, *args, &block
  end

  def error(*args, &block)
    log :error, *args, &block
  end

  def success(*args, &block)
    log :success, *args, &block
  end

  def debug?
    level <= REQUIRED_LOG_LEVELS[:debug]
  end

  def info?
    level <= REQUIRED_LOG_LEVELS[:info]
  end

  def warn?
    level <= REQUIRED_LOG_LEVELS[:warn]
  end

  def error?
    level <= REQUIRED_LOG_LEVELS[:error]
  end

  private

  REQUIRED_LOG_LEVELS = {
    debug:    ::Logger::DEBUG,
    info:     ::Logger::INFO,
    warn:     ::Logger::WARN,
    error:    ::Logger::ERROR,
    success:  ::Logger::INFO
  }

  def log(sym, *args, &block)
    log_level = level
    required_log_level = REQUIRED_LOG_LEVELS.fetch(sym)
    return if required_log_level < log_level

    msg = args.shift
    if msg.nil? && args.empty? && block
      msg = yield
      return if msg.nil?
    end

    formatted_runtime = "%.3f secs" % (Time.now - @@started_at)
    msg = "[#{formatted_runtime}] #{msg}"
    unless args.empty?
      msg += ": " + args.map(&:inspect).join(", ")
    end

    msg_length = msg.length

    if (color = COLORS[MESSAGE_COLOR[sym]])
      msg = "#{color}#{msg}#{COLORS[:clear]}"
    end

    if log_level < Logger::INFO
      padding = " " * (90 - msg_length) if msg_length < 90
      msg = "#{msg}#{padding}"
      msg = "#{msg}from #{source_from_caller}"
    end

    STDERR.puts msg
  end

  # [TODO] The heuristic used to determine the caller is not perfect.
  # Maybe we'll find a better solution; but for now this has to do.
  def source_from_caller
    source = caller.find do |loc|
      # skip this gem
      next false if loc =~ /\/lib\/simple\/cli\//

      # skip forwardable from Ruby stdlib
      next false if loc =~ /\/forwardable.rb\:/

      # skip simple-sql
      next false if loc =~ /\/lib\/simple\/sql\b/

      # skip lib/postjob/queue/postgres/checked_sql.rb
      next false if loc =~ %r{lib/postjob/queue/postgres/checked_sql.rb}

      true
    end

    source ||= caller[2]
    source = source[(wd.length + 1)..-1] if source.start_with?(wd)
    source
  end

  def wd
    @wd ||= Dir.getwd
  end
end
