studios = [
  {
    "name": "Seattle Fremont Studio",
    "lat": 47.649085,
    "lon": -122.348158
  },
  {
    "name": "Pioneer Square Studio",
    "lat": 47.598570,
    "lon": -122.333800
  },
  {
    "name": "Denver",
    "lat": 39.749902,
    "lon": -104.5 # actually -104.998871, shifted to avoid daylight savings bug
  },
  {
    "name": "Washington D.C.",
    "lat": 38.897681,
    "lon": -77.070522
  },
  {
    "name": "Melbourne",
    "lat": -37.815717,
    "lon": 144.957161
  },
  {
    "name": "Sydney",
    "lat": -33.862888,
    "lon": 151.207366
  },
  {
    "name": "Adelaide",
    "lat": -34.925938,
    "lon": 138.598763
  },
  {
    "name": "Perth",
    "lat": -31.952674,
    "lon": 115.851830
  },
  {
    "name": "Toronto",
    "lat": 43.644021,
    "lon": -79.394552
  },
  {
    "name": "London",
    "lat": 51.515392,
    "lon": -0.105597
  },
  {
    "name": "Mumbai",
    "lat": 19.075984,
    "lon": 72.877656
  },
  {
    "name": "Tokyo",
    "lat": 35.681183,
    "lon": 139.763770
  },
  {
    "name": "Johannesburg",
    "lat": -26.060800,
    "lon": 28.085450
  },
  {
    "name": "Stellenbosch",
    "lat": -33.939344,
    "lon": 18.858045
  }
]

daysArr = (startDate, endDate) ->
  arr = []
  currentDate = startDate
  while currentDate <= endDate
    arr.push(new Date(currentDate))
    nextDate = new Date(currentDate.valueOf())
    nextDate.setDate nextDate.getDate() + 1
    currentDate = nextDate
  arr

allDates = daysArr(new Date(2015, 0, 1), new Date(2015, 11, 31))

allDayLengths = []
for studio in studios
  studio.dayLengths = allDates.map (date) ->
    times = suncalc.getTimes date, studio.lat, studio.lon
    dayLength = (times.sunset.valueOf() - times.sunrise.valueOf()) / 3600000
    allDayLengths.push dayLength
    {
      date: date
      dayLength: dayLength
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
      x(d.date)
    .y (d) ->
      y(d.dayLength)

colors = d3.scale.category20()

totalWidth = width + margin.left + margin.right
totalHeight = height + margin.top + margin.bottom
svg = d3.select('.chart').append('svg')
    .attr('id', 'day-length-chart')
    .attr('viewBox', '0 0 ' + totalWidth + ' ' + totalHeight)
  .append('g')
    .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')

x.domain d3.extent allDates
y.domain d3.extent allDayLengths

svg.append('g')
    .attr('class', 'x axis')
    .attr('transform', 'translate(0,' + height + ')')
    .call(xAxis)

svg.append('g')
    .attr('class', 'y axis')
    .call(yAxis)

for studio, index in studios
  svg.append('g')
      .attr('class', 'studio-line')
      .attr('data-studio-name', studio.name)
    .append('path')
      .datum(studio.dayLengths)
      .attr('class', 'line')
      .attr('d', line)
      .style('stroke', colors(index))

# behavior for studio label mouseover


for studioLabel in document.querySelectorAll('.studio-label')
  
  studioLabel.addEventListener 'mouseover', (event) ->
    studioName = @getAttribute 'data-studio-name'
    document.querySelector('#day-length-chart').classList.add 'studio-highlighted'
    d3.selectAll('.studio-line').classed 'highlighted', false
    d3.select("g[data-studio-name='#{studioName}']").classed 'highlighted', true

  studioLabel.addEventListener 'mouseout', (event) ->
    document.querySelector('#day-length-chart').classList.remove 'studio-highlighted'
    d3.selectAll('.studio-line').classed 'highlighted', false
