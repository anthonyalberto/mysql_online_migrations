mysql_online_migrations
=======================

Patch Rails migrations to support MySQL 5.6 online migrations capabilities.  
Prior to MySQL 5.6, when adding / removing / renaming indexes and columns, MySQL would lock the writes of the whole table.  
MySQL 5.6 adds a way to append `LOCK=NONE` to those alter table statements to allow online migrations.


Requirements
=======================
Built for Rails 3.2.15, may be compatible with Rails 4.0 but you'd lose the new features introduced.  
This gem actually just requires ActiveRecord and ActiveSupport, the full Rails gem should not be required.

List of requirements :

- Use mysql2 adapter
- Use ActiveRecord "~> 3.2.15"
- Use MySQL or Percona Server 5.6.X

Scope of this gem
=======================

Patch Rails migrations to automatically add `LOCK=NONE` in the following context :

- Index management : `add_index`, `remove_index`, `rename_index`
- Add column : `add_column`, `add_timestamps`
- Remove column : `remove_column`, `remove_timestamps`

Usage
=======================
In a typical Rails app, just add it to your Gemfile :  
`gem 'mysql_online_migrations'`

Then run `bundle install`

You're ready for online migrations! Please read the caveats section though.

### Turn it off for a whole environment
Example for environment test (your CI might not use MySQL 5.6 yet), add the following to `config/environments/test.rb`:  
`config.active_record.mysql_online_migrations = false`

### Turn it off for a specific statement
Add `lock: true` to any of the method calls mentioned above. Example :  
`add_index :users, :name, lock: true`

The `lock: none` will be useful when hitting the caveats of `LOCK=NONE`. Please read the following section.

Caveats
=======================

Here's a list of things you can't do with LOCK=NONE and therefore you should provide `lock: true`:  

- Index a column of type text
- Change the type of a column
- Change the length of a column
- Change the nullable value of a column
- When adding an AUTO_INCREMENT column,
- Other stuff found on https://blogs.oracle.com/mysqlinnodb/entry/online_alter_table_in_mysql :
  - when the table contains FULLTEXT indexes or a hidden FTS_DOC_ID column, or
  - when there are FOREIGN KEY constraints referring to the table, with ON…CASCADE or ON…SET NULL option.

If you don't use `lock: true` when it's not supported, you'll get a MySQL exception. No risk to lock the table by accident.  
It's therefore highly recommended to use it in development/test/staging environment before running migrations in production.
