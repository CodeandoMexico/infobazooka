module JSONGenerator
  refine BSON::ObjectId do

    def as_json *args
      self.to_s
    end

  end
end