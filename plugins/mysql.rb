provides "mysql"

require_plugin 'linux::lsb'

def mysql_status()
  command = "#{mysqladmin_bin()} status"
  status, stdout, stderr = run_command(:no_status_check => true,
                                       :command => command)
  mysqlstatus = stdout.strip
  return Hash[mysqlstatus.scan(/(\w+): (\w+)/).map { |(k, v)| [k.downcase.to_sym, v.to_i] }]
end

def max_sql_connections()
  command = <<-EOS
    #{mysql_bin()} -e 'show variables like "max_connections"' -B | tail -n 1 | awk '{print $2}'
  EOS

  status, stdout, stderr = run_command(:no_status_check => true,
                                       :command => command)
  return stdout.to_i
end

def mysql_bin()
  unless @mysql_bin
    command = "which mysql"
    status, stdout, stderr = run_command(:no_status_check => true,
                                         :command => command)
    mysql_bin = stdout.strip
  end
  return mysql_bin unless mysql_bin.empty?
end

def mysqlserver_bin()
  unless @mysqlserver_bin
    command = "which mysqld"
    status, stdout, stderr = run_command(:no_status_check => true,
                                         :command => command)
    mysqlserver_bin = stdout.strip
  end
  return mysqlserver_bin unless mysqlserver_bin.empty?
end

def mysqladmin_bin()
  unless @mysqladmin_bin
    command = "which mysqladmin"
    status, stdout, stderr = run_command(:no_status_check => true,
                                         :command => command)
    mysqladmin_bin = stdout.strip
  end
  return mysqladmin_bin unless mysqladmin_bin.empty?
end

# Make sure we are on a MySQL Server and have the `mysql` command
if mysql_bin() && mysqlserver_bin()
  mysql Mash.new
  mysql[:bin] = mysqlserver_bin()
  mysql[:status] = mysql_status()
  mysql[:configuration] = {
    :max_connections => max_sql_connections()
  }
end