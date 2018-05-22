mysql\_online\_migrations
=======================

Patch Rails migrations to enforce MySQL 5.6 online migrations
Prior to MySQL 5.6, when adding / removing / renaming indexes and columns, MySQL would lock the writes of the whole table.
MySQL 5.6 by default will try to apply the least locking possible. You however don't know what kind of locking it applies and there's situations where it can't allow writes during a migration (See Caveats).
This gem enforces `LOCK=NONE` in all migration statements of Rails. Therefore, you're getting an error when MySQL cannot write during the migration so there's no surprise when rolling out in production.


Requirements
=======================
Built for Rails 3.2.15+, including Rails 4.

List of requirements :

- Use mysql2 adapter
- Use Rails ">= 3.2.15"
- Use MySQL or Percona Server 5.6.X with InnoDB

Scope of this gem
=======================

Patch Rails migrations to automatically add `LOCK=NONE` when issuing `ALTER`, `CREATE INDEX`, `CREATE UNIQUE INDEX`. `DROP INDEX` statements from any methods of ActiveRecord:

- Index management : `add_index`, `remove_index`, `rename_index`
- Add column : `add_column`, `add_timestamps`
- Remove column : `remove_column`, `remove_timestamps`
- Change column : `change_column`, `change_column_null`, `change_column_default`
- Any other method that was added in Rails 4 etc ...

__Please note that it only modifies sql queries sent in Rails Migrations.__
This way we avoid patching all of ActiveRecord statements all the time.

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
Call your migration statement within `with_lock` method. Example :

```
with_lock do
  add_index :my_table, :my_field
end
```

The `with_lock` method will be useful when hitting the caveats of `LOCK=NONE`. Please read the 'Caveats' section.

### Enable verbose output
To enable an 'ONLINE MIGRATION' debug statement whenever an online migration is
run, simply set the `MysqlOnlineMigrations.verbose` module variable to true.
Example (in a Rails app's config/initializers/mysql\_online\_migrations.rb):
```
MysqlOnlineMigrations.verbose = true
```

Caveats
=======================

The MySQL manual contains a list of which DDL statements can be run with `LOCK=NONE` under [Table 14.5 Summary of Online Status for DDL Operations](http://dev.mysql.com/doc/refman/5.6/en/innodb-create-index-overview.html).  The short version is that __you can not yet__:

- Index a column of type text
- Change the type of a column
- Change the length of a column
- Set a column to NOT NULL (at least not with the default SQL\_MODE)
- Adding an AUTO\_INCREMENT column,

If you don't use the `with_lock` method when online migration is not supported, you'll get a MySQL exception. No risk to lock the table by accident.
It's therefore highly recommended to use it in development/test/staging environment before running migrations in production.
If you have to perform such a migration without locking the table, tools such as [pt-online-schema-change](http://www.percona.com/doc/percona-toolkit/2.1/pt-online-schema-change.html) and [LHM](https://github.com/soundcloud/lhm) are viable options
