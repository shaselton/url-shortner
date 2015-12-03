require 'bijective'

class UrlController < ApplicationController
	 skip_before_filter :verify_authenticity_token, :only => [:index]
	def show
		url = Url.find_by(id: Bijective.bijective_decode(params['url']))
		if url
			redirect_to url.original
		else
			render json: {status: :not_found}
		end
	end

	def create
		original = params[:original_url]
		url = Url.find_by(original: params[:original_url])
		unless url
			url = Url.create(original: params[:original_url])
		end
		render json: {shorten_url: url.new}
	end
end