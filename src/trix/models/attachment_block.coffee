#= require trix/models/text

{arraysAreEqual, extend} = Trix

class Trix.AttachmentBlock extends Trix.Block
  constructor: (@attachment) ->
    super(null, ["attachment"])

  hasAttachment: ->
    true

  getAttachment: ->
    @attachment

  isEmpty: ->
    false

  isListItem: ->
    false

  toJSON: ->
    attachment: @attachment.toJSON()

  # Splittable

  getLength: ->
    1

  canBeConsolidatedWith: ->
    false

  # Grouping

  canBeGrouped: ->
    false

  canBeGroupedWith: ->
    false
