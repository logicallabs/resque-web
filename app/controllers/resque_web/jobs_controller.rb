module ResqueWeb
  class JobsController < ApplicationController
    def destroy
      Resque::Job.destroy(*[params['id'],
              params['class'],
              signaturize_params].flatten)

      flash[:success] = "Job removed from queue."
      redirect_to queue_path(params[:id])
    end

    private

    def signaturize_params
      klass = params['class'].constantize
      klass::SIGNATURE.zip(params['args']).map do |k, v|
        if k == 'string'
          v.to_s
        elsif k == 'integer'
          v.to_i
        elsif k == 'boolean'
          v = v == 'true' ? true : false
        end
      end
    end
  end
end
