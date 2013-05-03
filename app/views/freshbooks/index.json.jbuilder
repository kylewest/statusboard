json.graph do
  json.title 'Sales'
  json.total true
  json.yAxis do
    json.units do
      json.prefix '$'
    end
  end
  json.datasequences [@freshbooks.this_month, @freshbooks.last_month] do |i|
    json.title Date.new(2000, i, 1).strftime("%b")
    sales = @freshbooks.data.select{|k,v| Date.parse(k).month == i }.to_a.sort
    json.datapoints sales do |payment|
      json.title Date.parse(payment[0]).day.to_s
      json.value payment[1]
    end
  end
end
