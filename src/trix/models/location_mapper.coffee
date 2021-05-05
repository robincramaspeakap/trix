{elementContainsNode, findChildIndexOfNode, findClosestElementFromNode, findNodeFromContainerAndOffset,
 nodeIsBlockStart, nodeIsBlockStartComment, nodeIsBlockContainer, nodeIsCursorTarget,
 nodeIsEmptyTextNode, nodeIsTextNode, nodeIsAttachmentElement, tagName, walkTree} = Trix

class Trix.LocationMapper
  constructor: (@element) ->

  findLocationFromContainerAndOffset: (container, offset, {strict} = strict: true) ->
    childIndex = 0
    foundBlock = false
    location = index: 0, offset: 0

    walker = walkTree(@element, usingFilter: rejectAttachmentContents)

    while walker.nextNode()
      node = walker.currentNode

      if nodeIsAttachmentElement(node)
        location.index++
        location.offset = 0
        break if node.firstElementChild is container
      else if node is container and nodeIsTextNode(container)
        unless nodeIsCursorTarget(node)
          location.offset += offset
        break

      else
        if node.parentNode is container
          break if childIndex++ is offset
        else unless elementContainsNode(container, node)
          break if childIndex > 0

        if nodeIsBlockStart(node, {strict})
          location.index++ if foundBlock
          location.offset = 0
          foundBlock = true
        else
          location.offset += nodeLength(node)

    location

  findContainerAndOffsetFromLocation: (location) ->
    if location.index is 0 and location.offset is 0
      container = @element
      offset = 0

      while container.firstChild
        container = container.firstChild
        if nodeIsBlockContainer(container)
          offset = 1
          break

      return [container, offset]

    [node, nodeOffset] = @findNodeAndOffsetFromLocation(location)
    return unless node

    if nodeIsAttachmentElement(node)
      container = node.firstElementChild
      offset = 0
    else if nodeIsTextNode(node)
      container = node
      string = node.textContent
      offset = location.offset - nodeOffset

    else
      container = node.parentNode

      unless nodeIsBlockStart(node.previousSibling)
        unless nodeIsBlockContainer(container)
          while node is container.lastChild
            node = container
            container = container.parentNode
            break if nodeIsBlockContainer(container)

      offset = findChildIndexOfNode(node)
      offset++ unless location.offset is 0

    [container, offset]

  findNodeAndOffsetFromLocation: (location) ->
    offset = 0

    for currentNode in @getSignificantNodesForIndex(location.index)
      length = nodeLength(currentNode)

      if location.offset <= offset + length
        if nodeIsTextNode(currentNode)
          node = currentNode
          nodeOffset = offset
          break if location.offset is nodeOffset and nodeIsCursorTarget(node)

        else if not node
          node = currentNode
          nodeOffset = offset

      offset += length
      break if offset > location.offset

    [node, nodeOffset]

  # Private

  getSignificantNodesForIndex: (index) ->
    nodes = []
    walker = walkTree(@element, usingFilter: acceptSignificantNodes)
    recordingNodes = false

    while walker.nextNode()
      node = walker.currentNode
      if nodeIsBlockStartComment(node) or nodeIsAttachmentElement(node)
        if blockIndex?
          blockIndex++
        else
          blockIndex = 0

        if blockIndex is index
          if nodeIsAttachmentElement(node)
            nodes.push(node)
          else
            recordingNodes = true
        else if recordingNodes
          break
      else if recordingNodes
        nodes.push(node)

    nodes

  nodeLength = (node) ->
    if node.nodeType is Node.TEXT_NODE
      if nodeIsCursorTarget(node)
        0
      else
        string = node.textContent
        string.length
    else if tagName(node) is "br" or nodeIsAttachmentElement(node)
      1
    else
      0

  acceptSignificantNodes = (node) ->
    if rejectEmptyTextNodes(node) is NodeFilter.FILTER_ACCEPT
      rejectAttachmentContents(node)
    else
      NodeFilter.FILTER_REJECT

  rejectEmptyTextNodes = (node) ->
    if nodeIsEmptyTextNode(node)
      NodeFilter.FILTER_REJECT
    else
      NodeFilter.FILTER_ACCEPT

  rejectAttachmentContents = (node) ->
    if nodeIsAttachmentElement(node.parentNode)
      NodeFilter.FILTER_REJECT
    else
      NodeFilter.FILTER_ACCEPT
