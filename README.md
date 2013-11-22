mysql_online_migrations
=======================

Patch Rails migrations to support MySQL 5.6 online migrations capabilities.  
Prior to MySQL 5.6, when adding / removing / renaming indexes and columns, MySQL would lock the writes of the whole table.  
MySQL 5.6 adds a way to append `LOCK=NONE` to those alter table statements to allow online migrations.

Scope of this gem
=======================

Patch Rails migrations to automatically add `LOCK=NONE` in the following context :

- Index management : `add_index`, `remove_index`, `rename_index`
- Add column : `add_column`, `add_timestamps`, `add_reference`
- Remove column : `remove_column`, `remove_timestamps`, `remove_reference`

MySQL is not compatible with `LOCK=NONE` for a few edge cases
Therefore, we'll add an option to be able to prevent adding `LOCK=NONE`. `lock: true` should do the job.  
