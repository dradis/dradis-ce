json.partial! 'dradis/ce/api/v3/cards/card', card: @card
json.extract! @card, :list_id, :previous_id
