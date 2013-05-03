class FreshbooksController < ApplicationController
  http_basic_authenticate_with :name => ENV['HTTP_BASIC_AUTH_NAME'], :password => ENV['HTTP_BASIC_AUTH_PASSWORD']
  def index
    logger.debug "Freshbooks domain: #{ENV["FRESHBOOKS_DOMAIN"]}"
    @connection = FreshBooks::Client.new(ENV['FRESHBOOKS_DOMAIN'], ENV['FRESHBOOKS_API_KEY'])
    @freshbooks = Freshbooks.new

    # payment
    now = Date.today
    this_month = now.month
    last_month = now.prev_month.month
    date = Date.new(now.year, last_month, 1)
    freshbooks_response = @connection.payment.list :date_from => date, :per_page => 100
    pages = freshbooks_response['payments']['pages'].to_i
    payments = []
    pages.times do | page |
      page = page + 1
      if(page != 1)
        freshbooks_response = @connection.payment.list :date_from => date, :per_page => 100, :page => page
      end
      payments = payments + freshbooks_response['payments']['payment'].collect { |x| { :date => x['date'], :amount => x['amount'].to_f } }
    end

    @freshbooks.data = Hash.new(0)
    payments.each do |payment|
      @freshbooks.data[payment[:date]] += payment[:amount]
    end

    @freshbooks.this_month = this_month
    @freshbooks.last_month = last_month
  end
end
