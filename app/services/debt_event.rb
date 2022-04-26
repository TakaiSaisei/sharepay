class DebtEvent
  class << self
    def all(debt)
      account_scope = [debt.creditor_id, debt.debtor_id]
      events = UserPurchase.where(user_id: account_scope) | Payment.where(sender_id: account_scope, receiver_id: account_scope)

      events.each_with_object([]) do |event, ary|
        case event
        when UserPurchase
          ary << new(amount: event.amount, date: event.purchase.purchased_at, type: :purchase,
                     user_received_id: event.user_id, user_lost_id: event.purchase.user_id,
                     description: event.purchase.description, emoji: event.purchase.emoji)
        when Payment
          ary << new(amount: event.amount, date: event.created_at, type: :payment,
                     user_received_id: event.receiver_id, user_lost_id: event.sender_id)
        else
          raise StandardError, "Unknown debt event #{event.class.name}"
        end
      end
    end
  end

  attr_accessor :amount, :date, :type, :user_lost_id, :user_received_id, :description, :emoji

  def initialize(amount:, date:, type:, user_lost_id:, user_received_id:, description: nil, emoji: nil)
    @amount = amount
    @date = date
    @type = type
    @user_lost_id = user_lost_id
    @user_received_id = user_received_id
    @description = description
    @emoji = emoji
  end
end
