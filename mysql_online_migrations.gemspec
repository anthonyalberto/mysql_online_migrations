Gem::Specification.new do |s|
  s.name        = 'mysql_online_migrations'
  s.version     = '1.0.3'
  s.summary     = "Use MySQL 5.6+ capacities to enforce online migrations"
  s.description = "MySQL 5.6 adds a `LOCK=NONE` option to make sure migrations are done with no locking. Let's use it."
  s.authors     = ["Anthony Alberto"]
  s.email       = 'alberto.anthony@gmail.com'
  s.homepage    = 'https://github.com/anthonyalberto/mysql_online_migrations'

  s.add_runtime_dependency "activerecord", ">= 3.2.15", "< 5.1.0"
  s.add_runtime_dependency "activesupport", ">= 3.2.15", "< 5.1.0"
  s.add_runtime_dependency "mysql2"
  s.add_development_dependency "logger"
  s.add_development_dependency "rspec"
  s.add_development_dependency "pry"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.license = 'MIT'
end
