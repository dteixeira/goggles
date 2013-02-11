# Container class for Goggles response messages
class GogglesMessage

  attr_accessor :message, :type

  def initializer (type = nil, message = nil)
    @type = type
    @message = message
  end

end
