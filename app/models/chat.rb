# == Schema Information
#
# Table name: chats
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           not null
#  history    :json
#  q_and_a    :string           default([]), is an Array
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Chat < ApplicationRecord
  belongs_to :user

  attr_accessor :message

  def message=(message)
    self.history = { 'prompt' => message, 'history' => [] } if history.blank?

    messages = [
      { 'role' => 'system', 'content' => history['prompt'] }
    ]

    q_and_a.each do |question, answer|
      messages << { 'role' => 'user', 'content' => question }
      messages << { 'role' => 'assistant', 'content' => answer }
    end
    messages << { 'role' => 'user', 'content' => message } if messages.size > 1


    conn = Faraday.new(url: 'http://localhost:11434') do |faraday|
      faraday.request :json
      faraday.response :json, content_type: /\bjson$/
      faraday.adapter Faraday.default_adapter
    end

    payload = {
      model: "llama3",
      prompt: message,
      stream: false
    }

    response = conn.post '/api/generate', payload.to_json, { 'Content-Type' => 'application/json' }

    self.q_and_a << [message, JSON.parse(response.to_json, object_class: OpenStruct).body.response]
  end
end
