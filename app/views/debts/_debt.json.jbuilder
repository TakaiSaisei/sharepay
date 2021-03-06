with_events = false unless defined?(:with_events)

json.id debt.id
json.amount debt.amount
json.creditor_phone debt.creditor.phone
json.debtor_phone debt.debtor.phone

if with_events
  json.events do
    json.array! debt.events do |event|
      json.amount current_user.id == event.user_lost_id ? -event.amount : event.amount
      json.date event.date
      json.name event.name
      json.emoji event.emoji
      json.type event.type
      json.event_id event.event_id
    end
  end
end
