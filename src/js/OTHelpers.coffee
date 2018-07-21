streamElements = {} # keep track of DOM elements for each stream

# Whenever updateViews are involved, parameters passed through will always have:
# TBPublisher constructor, TBUpdateObjects, TBSubscriber constructor
# [id, top, left, width, height, zIndex, ... ]

#
# Helper methods
#
getPosition = (divOrDivName) ->
  # Get the position of element
  pubDiv = if typeof divOrDivName is 'string' then document.getElementById(divOrDivName) else divOrDivName
  if !pubDiv then return {}
  rect = pubDiv.getBoundingClientRect()
  return {
    top:rect.top,
    left:rect.left,
    width:rect.width,
    height:rect.height
  }

replaceWithVideoStream = (divOrDivName, streamId, properties) ->
  typeClass = if streamId == PublisherStreamId then PublisherTypeClass else SubscriberTypeClass
  element = if typeof divOrDivName is 'string' then document.getElementById(divOrDivName) else divOrDivName
  element.setAttribute( "class", "OT_root #{typeClass}" )
  element.setAttribute( "data-streamid", streamId )
  element.style.width = properties.width+"px"
  element.style.height = properties.height+"px"
  element.style.overflow = "hidden"
  streamElements[ streamId ] = element

  internalDiv = document.createElement( "div" )
  internalDiv.setAttribute( "class", VideoContainerClass)
  internalDiv.style.width = "100%"
  internalDiv.style.height = "100%"
  internalDiv.style.left = "0px"
  internalDiv.style.top = "0px"

  videoElement = document.createElement( "video" )
  videoElement.style.width = "100%"
  videoElement.style.height = "100%"
  # todo: js change styles or append css stylesheets? Concern: users will not be able to change via css

  internalDiv.appendChild( videoElement )
  element.appendChild( internalDiv )
  return element

TBError = (error) ->
  if (window.OT.errorCallback)
    window.OT.errorCallback(error)
  else
    console.error(error)

TBSuccess = ->
  # console.log("success")

TBUpdateObjects = ()->
  # console.log("JS: Objects being updated in TBUpdateObjects")
  objects = document.getElementsByClassName('OT_root')

  ratios = TBGetScreenRatios()

  for e in objects
    # console.log("JS: Object updated")
    streamId = e.dataset.streamid
    # console.log("JS sessionId: " + streamId )
    position = getPosition(e)
    Cordova.exec(TBSuccess, TBError, OTPlugin, "updateView", [streamId, position.top, position.left, position.width, position.height, TBGetZIndex(e), ratios.widthRatio, ratios.heightRatio, TBGetBorderRadius(e)] )
  return

TBGenerateDomHelper = ->
  domId = "PubSub" + Date.now()
  div = document.createElement('div')
  div.setAttribute( 'id', domId )
  document.body.appendChild(div)
  return domId

TBGetZIndex = (ele) ->
  while( ele? )
    val = document.defaultView.getComputedStyle(ele,null).getPropertyValue('z-index')
    # console.log val
    if ( parseInt(val) )
      return val
    ele = ele.offsetParent
  return 0

TBGetScreenRatios = ()->
    # Ratio between browser window size and viewport size
    return {
        widthRatio: window.devicePixelRatio,
        heightRatio: window.devicePixelRatio
    }

TBGetBorderRadius = (ele) ->
  while( ele? )
    val = document.defaultView.getComputedStyle(ele,null).getPropertyValue('border-radius')
    if (val && (val.length > 1) && (val != '0px'))
      if (val.indexOf('%') == (val.length - 1))
        return Math.round(ele.offsetWidth * (parseFloat(val.substring(0, val.length - 1)) / 100))
      else if (val.indexOf('px') == (val.length - 2))
        return parseInt(val.substring(0, val.length - 2))
    ele = ele.offsetParent
  return 0

pdebug = (msg, data) ->
  console.log "JS Lib: #{msg} - ", data
