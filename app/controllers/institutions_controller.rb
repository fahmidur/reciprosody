class InstitutionsController < ApplicationController
	autocomplete :institution, :name, :full => true, :extra_data=>[:id]
end