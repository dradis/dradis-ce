json.working @working.nil? ? true : @working
json.after   @logs.any? ? @logs.last.id : params[:after].to_i
json.logs @logs do |log|
  json.id   log.id
  json.text log.read
end
