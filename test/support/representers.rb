class SpecRepresenter < Representer::Base
end

class UserRepresenter < Representer::Base
  namespace  "user"
  attributes "id", "name", "email"
end

class LightningUserRepresenter < Representer::Lightning
  namespace  "user"
  attributes "id", "name", "email"
end

class MessageRepresenter < Representer::Base
  attributes "id", "body", "user_id"
  fields     "user", "attachment"

  # aggregate "user_id" do |aggregated|
  #   @users = User.where(:id => aggregated).group_by(&:id)
  # end

  def before_prepare
    @user_ids = []
  end

  def after_prepare(prepared)
    @users = User.where(:id => @user_ids).group_by(&:id)
    super
  end

  def first_pass(object)
    @user_ids.push object.user_id
    super
  end

  def user(hash)
    if found = @users[hash.delete('user_id')]
      found.first
    end
  end

end

class MessageWithAttachmentRepresenter < MessageRepresenter

  fields "attachment"

  # aggregate "id" do |aggregated|
  #   @attachments = Attachment.where(:message_id => @ids).group_by(&:id)
  # end

  def attachment(hash)
    if found = @users[hash['id']]
      found
    end
  end

end

class DummyPreparationRepresenter < Representer::Base

  attributes "name"

  def first_name(hash)
    hash["name"].split(" ").first
  end

end

class DummyPreparationArrayedMethodsRepresenter < Representer::Base

  attributes "name"

  methods ["final_label", "custom_method"]
  fields  ["custom_label", "custom_field"]

  def first_name(hash)
    hash["name"].split(" ").first
  end

  def custom_field(hash)
    hash["name"].upcase.reverse
  end

end

class DummyPreparationHashedMethodsRepresenter < Representer::Base

  attributes "name"

  methods "custom_method" => "final_label"
  fields  "custom_field"  => "custom_label"

  def first_name(hash)
    hash["name"].split(" ").first
  end

  def custom_field(hash)
    hash["name"].upcase.reverse
  end

end
