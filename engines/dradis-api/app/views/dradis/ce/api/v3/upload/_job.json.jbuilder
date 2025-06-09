if @job_id
  json.job_id @job_id
end

json.state @state

if @message
  json.message @message
end
