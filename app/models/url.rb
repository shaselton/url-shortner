class Url < ActiveRecord::Base
	after_create :new_url

	def new_url
		self.new = Bijective.bijective_encode(self.id)
		self.save!
	end
end
