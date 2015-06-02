module ResqueWeb
  class OverviewController < ApplicationController
    def show
      render :layout => !request.xhr?, :locals => { :polling => request.xhr? }
    end

    def destroy
      if worker_has_many_queues?
        flash[:error] = "Cannot kill worker. \n
                        Worker: #{@worker} has #{@worker.queues.size} queues. \n
                        (PID: #{params['pid']})."
      else
        kill_worker
        label = params['job']['payload']['args'][0]
        start_worker
        flash[:success] = "#{label} failed, retry from the failed tab. Restarting Worker..."
      end
      redirect_to '/resque/#poll'
    end

    private

    def worker_has_many_queues?
      find_worker.queues.count > 1
    end

    def find_worker
      @worker = Resque::Worker.find(params[:worker_id])
    end

    def kill_worker
      Process.kill 'TERM', params['pid'].to_i
    end

    def start_worker
      Thread.new { system "rake resque:work QUEUE=#{params[:job][:queue]}" }
    end
  end
end
