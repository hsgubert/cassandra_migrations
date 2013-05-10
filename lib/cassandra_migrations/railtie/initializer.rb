# encoding : utf-8

# Em produção (como usamos o Passenger), vários processos ruby são criados através do fork
# do original. No UNIX, quando um fork é realizado, is file descriptors (arquivos, conexões a base de dados,
# sockets, e etc) são copiados em estado aberto para o processo filho. Se não reabrirmos a conexão com o cassandra
# no processo filho, quando ela for ser usada ela estará 'locked' pelo processo pai, o que resultará em deadlock. 

# Mais explicações em: http://www.modrails.com/documentation/Users%20guide%20Apache.html#spawning_methods_explained
if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    if forked
      CassandraMigrations::Cassandra.restart!
    end
  end
else
  CassandraMigrations::Cassandra.start!
end
