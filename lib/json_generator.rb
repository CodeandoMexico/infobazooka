class BSON::ObjectId
  def as_json *args
    self.to_s
  end
end