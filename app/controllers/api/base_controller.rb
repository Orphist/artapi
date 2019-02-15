module Api
  class BaseController < ActionController::API
    include CleanPagination

    MAX_LIMIT_PER_PAGE ||= 100

    respond_to :json

    rescue_from Exception do |exception|
      case exception
      when ActiveRecord::RecordNotFound
        render_response(404, {})
      else
        logger.error 'Error 500 is rendered by Api::BaseController:'
        logger.error exception.message
        exception.backtrace.each do |line|
          logger.error line
        end
        #ToDo: send it to Rollbar, Prometheus etc
        render_response(500, {})
      end
    end

    def render_response(status, response)
      render status: status, json: response.to_json
    end

    def max_limit_per_page
      MAX_LIMIT_PER_PAGE
    end

  end
end
