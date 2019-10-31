h = {
  1 => [[:issue, ['hello', 'warudo']]],
  2 => [[:issue, ['test']], [:note, ['mic']]]
}

h.each_with_object({}) do |p_notifs, memo|
  raise [p_notifs, memo].inspect
end
