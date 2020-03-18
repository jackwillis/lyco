class ActivityLog
  def initialize(redis, iodev = STDOUT)
    @redis = redis
    @iodev = iodev
  end

  def info(msg)
    log :info, msg
  end

  def warn(msg)
    log :warn, msg
  end

  def error(msg)
    log :error, msg
  end

  def log(severity, msg)
    write_redis(severity, msg)
    write_iodev(severity, msg)
  end

  def self.all
    
  end

  private

  def write_redis(severity, msg)

  end

  def write_iodev(severity, msg)
    time_str = Time.now.strftime '%Y-%m-%d %H:%M.%L %z'
    @iodev.puts "[#{time_str}] #{severity.upcase}: #{msg}"
  end

end
