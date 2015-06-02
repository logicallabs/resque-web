module ResqueWeb
  class OverviewController < ApplicationController
    def show
      render :layout => !request.xhr?, :locals => { :polling => request.xhr? }
    end

    def destroy
      kill_worker
      label = params['job']['payload']['args'][0]
      start_worker
      redirect_to '/resque/#poll', notice: "#{label} failed, retry from the failed tab. Restarting Worker..."
    end

    private

    def kill_worker
      Process.kill 'TERM', params['pid'].to_i
    end

    def start_worker
      Thread.new { system "rake resque:work QUEUE=#{params[:job][:queue]}" }
    end
  end
end
