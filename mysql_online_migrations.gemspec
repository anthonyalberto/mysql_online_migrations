Gem::Specification.new do |s|
  s.name        = 'mysql_online_migrations'
  s.version     = '0.1.0'
  s.summary     = "Use MySQL 5.6+ capacities to perform online migrations"
  s.description = "MySQL 5.6 adds a way to append `LOCK=NONE` to alter table statements to allow online migrations. Let's use it."
  s.authors     = ["Anthony Alberto"]
  s.email       = 'alberto.anthony@gmail.com'
  s.files       = ["lib/mysql_online_migrations.rb"]
  s.homepage    = 'https://github.com/anthonyalberto/mysql_online_migrations'

  s.add_runtime_dependency "activerecord", "~> 3.2.15"
  s.add_runtime_dependency "activesupport", "~> 3.2.15"
  s.add_runtime_dependency "mysql2"
  s.add_development_dependency "logger"
  s.add_development_dependency "rspec"
  s.add_development_dependency "pry"
end