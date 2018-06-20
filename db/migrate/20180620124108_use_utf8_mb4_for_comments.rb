class UseUtf8Mb4ForComments < ActiveRecord::Migration[5.1]
  def up
    execute "ALTER TABLE comments CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci"
    execute "ALTER TABLE comments MODIFY content TEXT CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci"
  end

  def down
    execute "ALTER TABLE comments CHARSET utf8 COLLATE utf8_bin"
    execute "ALTER TABLE comments MODIFY content TEXT CHARSET utf8 COLLATE utf8_bin"
  end
end
