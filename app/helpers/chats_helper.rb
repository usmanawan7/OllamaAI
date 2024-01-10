module ChatsHelper
  def list_name(chat)
    if chat.q_and_a.present?
      chat.q_and_a.first[0].truncate(20)
    else
      "Chat #{chat.id}"
    end
  end
end
