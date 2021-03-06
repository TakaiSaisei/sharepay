class DebtEvent
  class << self
    def all(debt)
      account_scope = [debt.creditor_id, debt.debtor_id]
      events = []

      account_scope.each do |acc|
        events << (UserPurchase.includes(:purchase)
                              .where(user_id: acc)
                              .where(purchases: { draft: false, user_id: account_scope - [acc] })
                              .where('purchases.user_id != user_purchases.user_id') |
          Payment.where(sender_id: account_scope, receiver_id: account_scope))
      end

      events.flatten.uniq.each_with_object([]) do |event, ary|
        case event
        when UserPurchase
          ary << new(amount: event.amount, date: event.purchase.purchased_at, type: :purchase,
                     user_received_id: event.user_id, user_lost_id: event.purchase.user_id,
                     name: event.purchase.name, emoji: event.purchase.emoji,
                     event_id: event.purchase_id)
        when Payment
          ary << new(amount: event.amount, date: event.created_at, type: :payment,
                     user_received_id: event.receiver_id, user_lost_id: event.sender_id,
                     event_id: event.id)
        else
          raise StandardError, "Unknown debt event #{event.class.name}"
        end
      end
    end
  end

  attr_accessor :amount, :date, :type, :user_lost_id, :user_received_id, :name, :emoji, :event_id

  def initialize(amount:, date:, type:, user_lost_id:, user_received_id:, event_id:, name: nil, emoji: nil)
    @amount = amount
    @date = date
    @type = type
    @user_lost_id = user_lost_id
    @user_received_id = user_received_id
    @event_id = event_id
    @name = name
    @emoji = emoji
  end
end
