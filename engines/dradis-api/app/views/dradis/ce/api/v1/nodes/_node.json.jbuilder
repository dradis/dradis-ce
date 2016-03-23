json.(node, :id, :label, :type_id, :parent_id, :position, :created_at, :updated_at)

json.evidence node.evidence do |evidence|
  json.partial! evidence
end

json.notes node.notes do |note|
  json.partial! note
end
