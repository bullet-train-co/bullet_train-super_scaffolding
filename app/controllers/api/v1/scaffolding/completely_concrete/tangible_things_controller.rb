class Api::V1::Scaffolding::CompletelyConcrete::TangibleThingsController < Api::V1::ApplicationController
  account_load_and_authorize_resource :tangible_thing, through: :absolutely_abstract_creative_concept, through_association: :completely_concrete_tangible_things

  # GET /api/v1/scaffolding/absolutely_abstract/creative_concepts/:absolutely_abstract_creative_concept_id/completely_concrete/tangible_things
  def index
  end

  # GET /api/v1/scaffolding/completely_concrete/tangible_things/:id
  def show
  end

  # POST /api/v1/scaffolding/absolutely_abstract/creative_concepts/:absolutely_abstract_creative_concept_id/completely_concrete/tangible_things
  def create
    @absolutely_abstract_creative_concept = Scaffolding::AbsolutelyAbstract::CreativeConcept.find(params["absolutely_abstract_creative_concept_id"])
    @tangible_thing = @absolutely_abstract_creative_concept.completely_concrete_tangible_things.build(strong_parameters_from_api)

    @tangible_thing = Scaffolding::CompletelyConcrete::TangibleThing.new(strong_parameters_from_api)

    if @tangible_thing.save
      render :show, status: :created, location: [:api, :v1, @tangible_thing]
    else
      render json: @tangible_thing.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/scaffolding/completely_concrete/tangible_things/:id
  def update
    if @tangible_thing.update(strong_parameters_from_api)
      render :show
    else
      render json: @tangible_thing.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/scaffolding/completely_concrete/tangible_things/:id
  def destroy
    @tangible_thing.destroy
  end

  private

  module StrongParameters
    # Only allow a list of trusted parameters through.
    def self.tangible_thing_params(params, permitted_fields, permitted_arrays)
      strong_params = params.require(:scaffolding_completely_concrete_tangible_thing).permit(
        *permitted_fields,
        # 🚅 skip this section when scaffolding.
        :text_field_value,
        :action_text_value,
        :boolean_button_value,
        :button_value,
        :color_picker_value,
        :cloudinary_image_value,
        :date_field_value,
        :date_and_time_field_value,
        :date_and_time_field_value_time_zone,
        :email_field_value,
        :file_field_value,
        :file_field_value_removal,
        :option_value,
        :password_field_value,
        :phone_field_value,
        :super_select_value,
        :text_area_value,
        :absolutely_abstract_creative_concept_id,
        # 🚅 stop any skipping we're doing now.
        # 🚅 super scaffolding will insert new fields above this line.
        *permitted_arrays,
        # 🚅 skip this section when scaffolding.
        multiple_button_values: [],
        multiple_option_values: [],
        multiple_super_select_values: []
        # 🚅 stop any skipping we're doing now.
        # 🚅 super scaffolding will insert new arrays above this line.
      )

      Account::Scaffolding::CompletelyConcrete::TangibleThingsController.process_params(strong_params)

      strong_params
    end
  end

  include StrongParameters

  # Although our strong params are being filtered via strong_parameters_from_api,
  # Rails still requires us to invoke this method in the controller.
  # Otherwise we will get an ActiveModel::ForbiddenAttributes error.
  def tangible_thing_params
  end
end
