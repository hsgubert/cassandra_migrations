# encoding : utf-8

# In production (when Passenger is used with smart spawn), many ruby processes are created
# by forking the original spawner. Since the child process is a different process, it shares
# no memory with its father. Because of that we have to connect to cassandra again.
# It is also common that file descriptors are unintentionally shared when the process forks,
# that's why we go through the safe path and check if the client exists in order to restart it
# (production tests have shown that the client is nil when forked)

# More explanations in: http://www.modrails.com/documentation/Users%20guide%20Apache.html#spawning_methods_explained

module CassandraMigrations

  Cassandra.start!

  if defined?(Spring)
    Spring.after_fork do
      Cassandra.restart
    end
  end

  if defined?(PhusionPassenger)
    PhusionPassenger.on_event(:starting_worker_process) do |forked|
      if forked
        Cassandra.restart
      end
    end
  end
end
