class CallFlowLogic::BehaviorChange < CallFlowLogic::Base
  def to_xml(options = {})
    Twilio::TwiML::VoiceResponse.new do |response|
      response.say("Somalia Behaviour Change")
      response.play(:url => "https://s3.ap-south-1.amazonaws.com/unicef-somalia-ivr-2017/Barnaamijka+CTP.wav")
    end.to_s
  end
  
  def rapidpro_client
    @rapidpro_client ||= Rapidpro::Client.new
  end

  def run!
    super
    if event.phone_call.completed?
      response = rapidpro_client.start_flow!(
        {
          "flow":"624d16eb-b022-4ce4-84d8-31aa3103e20c"
          "urns": event.phone_call.msisdn
        } # Dynamically override default params here
    )
  end
end
