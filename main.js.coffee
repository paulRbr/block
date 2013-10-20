# Main namespace
# Make it publicly available
window.block = {}
b = window.block

b.start = () ->
  m = new b.MyMap()
  m.init({size: 10, el: "#container"})
  m.render()