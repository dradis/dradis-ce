namespace :sandbox do
  desc 'Enable Sandbox mode'
  task enable: :environment do
    file_path = Rails.root.join(Dradis.SANDBOX_FILE_PATH)
    FileUtils.mkdir_p(File.dirname(file_path))
    FileUtils.touch(file_path)
    puts "Sandbox mode enabled (#{file_path} created)"
  end

  desc 'Disable Sandbox mode'
  task disable: :environment do
    file_path = Rails.root.join(Dradis.SANDBOX_FILE_PATH)
    FileUtils.rm_f(file_path)
    puts "Sandbox mode disabled (#{file_path} removed)"
  end
end
