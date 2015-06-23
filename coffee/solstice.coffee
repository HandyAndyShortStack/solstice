seattle =
  name: 'Seattle Fremont Studio',
  lat: 47.649085,
  lon: -122.348158

daysArr = (startDate, endDate) ->
  arr = [];
  currentDate = startDate;
  while currentDate <= endDate
    arr.push(new Date(currentDate))
    nextDate = new Date(currentDate.valueOf())
    nextDate.setDate nextDate.getDate() + 1
    currentDate = nextDate;
  arr

allDates = daysArr(new Date(2015, 0, 1), new Date(2015, 11, 31))

dayLengths = allDates.map (date) ->
  times = suncalc.getTimes date, seattle.lat, seattle.lon
  {
    date: date
    dayLength: (times.sunset.valueOf() - times.sunrise.valueOf()) / 3600000
  }

# graphing

margin =
  top: 20
  right: 20
  bottom: 30
  left: 50

width = 960 - margin.left - margin.right
height = 500 - margin.top - margin.bottom

x = d3.time.scale()
    .range([0, width])

y = d3.scale.linear()
    .range([height, 0])

xAxis = d3.svg.axis()
    .scale(x)
    .orient('bottom')

yAxis = d3.svg.axis()
    .scale(y)
    .orient('left')

line = d3.svg.line()
    .x (d) ->
      console.log d.date
      x(d.date)
    .y (d) ->
      y(d.dayLength)

svg = d3.select('section.chart').append('svg')
    .attr('width', width + margin.left + margin.right)
    .attr('height', height + margin.top + margin.bottom)
  .append('g')
    .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')

x.domain d3.extent dayLengths, (d) ->
  d.date
y.domain d3.extent dayLengths, (d) ->
  d.dayLength

svg.append('g')
    .attr('class', 'x axis')
    .attr('transform', 'translate(0,' + height + ')')
    .call(xAxis)

svg.append('g')
    .attr('class', 'y axis')
    .call(yAxis)

svg.append('path')
    .datum(dayLengths)
    .attr('class', 'line')
    .attr('d', line)
