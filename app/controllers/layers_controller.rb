class LayersController < ApplicationController

  def select_fields
    job_params = {
      :name_field => params[:name],
      :class_field => params[:class],
      :layer_id => params[:id]
    }
    job_id = LayerUploadJob.create(job_params)
    render :json => {:job_id => job_id, :layer_id => params[:id]}
  end

  def get_job_status
    # Get the job status
    status = Resque::Plugins::Status::Hash.get(params[:job_id])

    # Sometimes the job claims its running when cartodb has imported, so check cartodb
    layer_id = status['options']['layer_id'] #use the first layer if more
    carto_count = CartoDB::Connection.query("SELECT cartodb_id FROM #{LayerUploadJob::TABLENAME} WHERE layer_id = #{layer_id} AND class_id IS NOT NULL")[:total_rows]

    # Set status completed if cartodb has rows
    status['status'] = 'completed' if carto_count > 0
    render :json => status
  end

  # JSON list of the associated uploaded polygon names
  def polygon_names
    polygons = CartoDB::Connection.query("SELECT cartodb_id, name FROM #{LayerUploadJob::TABLENAME} WHERE layer_id = #{params[:id]}")[:rows]

    render :json => polygons.to_json
  end

  def destroy
    layer = Layer.find(params[:id])

    if layer.destroy
      render :json => layer.to_json
    else
      render :json => {error: 'Could not delete layer'}
    end
  end
end
